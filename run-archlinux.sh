#!/bin/bash

# Set default user
DISTRO_USER_FILE=.lemoe_user
if [ -f "$DISTRO_USER_FILE" ]; then
    # Read the first line from the file
    read -r DISTRO_USER < $DISTRO_USER_FILE
else
    echo lemoe > $DISTRO_USER_FILE
    DISTRO_USER=lemoe
fi

# user parameters
BINDS=" --bind /storage/emulated/0/Documents:/media/documents"
BINDS=$BINDS" --bind /storage/emulated/0/Download:/media/downloads"
BINDS=$BINDS" --bind $HOME/something:/proc/bus/pci/devices"

# system parameters
DISTRO=archlinux
SCRIPT_DIR=$(dirname $(realpath "$0"))
DISTRO_LOGIN="proot-distro login $DISTRO $BINDS"
DISTRO_ROOTFS="$PREFIX/var/lib/proot-distro/installed-rootfs/$DISTRO"
DISTRO_BACKUP_DIR="$SCRIPT_DIR/distro_backup"
DISTRO_PROFILE_DIR="$SCRIPT_DIR/profile_backup"
DISTRO_USER_HOME=$DISTRO_ROOTFS/home/$DISTRO_USER

setup_termux() {
    PKGS="git vim proot-distro termux-x11-nightly pulseaudio"

    echo "Setting up termux ..."

    # Create dirs
    mkdir -p $DISTRO_BACKUP_DIR
    mkdir -p $DISTRO_PROFILE_DIR

    # Restore termux user profile
    restore_termux

    # Check if the package x11-repo is installed
    if [ $(dpkg --list | grep x11-repo | wc -l) -eq 0 ]; then
        termux-change-repo
        pkg update -y
        pkg install -y x11-repo
        termux-change-repo
    fi

    echo "Installing packages ..."
    pkg install -y $PKGS

    # fix pulseaudio for huawei
    if [ -e /system/framework/hwEmui.jar ]; then
        fix_audio
    fi
}

install_distro() {
    PKGS_XFCE4="xfce4 xfce4-goodies pavucontrol"
    PKGS_FONTS="adobe-source-han-sans-cn-fonts adobe-source-han-serif-cn-fonts noto-fonts-cjk wqy-microhei wqy-microhei-lite wqy-bitmapfont wqy-zenhei ttf-arphic-ukai ttf-arphic-uming"
    PKGS_IME="fcitx5-im fcitx5-chinese-addons fcitx5-material-color"
    PKGS_TOOLS="man sudo wget vim chromium base-devel zsh zsh-completions"
    echo "Installing distro $DISTRO ..."

    # install distro if not exists
    if [ ! -d "$DISTRO_ROOTFS" ]; then
        proot-distro install $DISTRO
    fi

    # install xfce4
    $DISTRO_LOGIN -- sed -i "s|http://mirror.archlinuxarm.org|http://mirrors.bfsu.edu.cn/archlinuxarm|g" /etc/pacman.d/mirrorlist
    $DISTRO_LOGIN -- pacman -Syyu --noconfirm
    $DISTRO_LOGIN -- pacman -S --noconfirm $PKGS_XFCE4 $PKGS_FONTS $PKGS_IME $PKGS_TOOLS
    # remove power manager
    $DISTRO_LOGIN -- pacman -R --noconfirm xfce4-power-manager xfce4-screensaver

    # set timezone 
    $DISTRO_LOGIN -- ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime 
}

setup_distro() {
    ETC="$DISTRO_ROOTFS/etc"
    LINE="$DISTRO_USER ALL=(ALL:ALL) NOPASSWD: ALL"
    FILE="$ETC/sudoers.d/$DISTRO"

    echo "Setting up distro $DISTRO ..."

    # create a new user
    $DISTRO_LOGIN -- useradd -m -G root -s /bin/bash $DISTRO_USER

    # enable sudoer for this user
    touch $FILE
    if ! grep -q "$LINE" $FILE; then
        echo "$LINE" >> $FILE
    fi
    echo "Done."

    # install vscode, if not installed yet
    if [ ! -e $DISTRO_ROOTFS/usr/share/applications/code.desktop ]; then
        install_vscode
    fi

    # update shrotcuts
    sed -i "s|Exec=/usr/bin/chromium|Exec=/usr/bin/chromium --no-sandbox|g" $DISTRO_ROOTFS/usr/share/applications/chromium.desktop
    sed -i "s|Exec=/usr/bin/code|Exec=/usr/bin/code --no-sandbox|g" $DISTRO_ROOTFS/usr/share/applications/code.desktop
}

build() {
    [ ! "$1" == "" ] && DISTRO_USER=$1
    echo $DISTRO_USER > $DISTRO_USER_FILE

    # Display the value of DISTRO_USER
    echo "DISTRO_USER is set to: $DISTRO_USER"

    # build distro
    setup_termux
    install_distro
    setup_distro
}

precheck() {
    # ensure proot-distro
    if [ $(dpkg --list | grep proot-distro | wc -l) -eq 0 ]; then
        setup_termux
    fi

    # ensure rootfs from backup
    if [ ! -d "$DISTRO_ROOTFS" ]; then
        restore_distro
    fi

    # ensure user profile
    if [ ! -d "$DISTRO_ROOTFS/home/$DISTRO_USER" ]; then
        setup_distro
    fi
}

login() {
    precheck
    [ ! "$1" == "" ] && LOGIN_USER="$1" || LOGIN_USER="root"
    $DISTRO_LOGIN --user $LOGIN_USER
}

start_x11() {
    echo "Starting x11 for $DISTRO ..."
    precheck
    pulseaudio --start --exit-idle-time=-1 --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1"
    am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity
    $DISTRO_LOGIN --shared-tmp --user $DISTRO_USER -- termux-x11 :1 -xstartup "dbus-launch --exit-with-session xfce4-session"
    echo "Cleaning up ..."
    killall -9 pulseaudio 2>/dev/null
    echo "Done."
    exit
}

backup_distro() {
    # Specify distro backup name
    if [ "$1" == "" ]; then
        DISTRO_BACKUP=$DISTRO_BACKUP_DIR/$DISTRO-base.tar.gz
    else
        DISTRO_BACKUP=$DISTRO_BACKUP_DIR/$DISTRO-$1.tar.gz
    fi
    echo "Backup $DISTRO image to $DISTRO_BACKUP"
    proot-distro backup $DISTRO --output $DISTRO_BACKUP
}

restore_distro() {
    # Specify distro backup name
    if [ "$1" == "" ]; then
        DISTRO_BACKUP=$DISTRO_BACKUP_DIR/$DISTRO-base.tar.gz
    else
        DISTRO_BACKUP=$DISTRO_BACKUP_DIR/$DISTRO-$1.tar.gz
    fi
    echo "Restore $DISTRO image from $DISTRO_BACKUP"
    if [ -e "$DISTRO_BACKUP" ]; then
        proot-distro restore $DISTRO_BACKUP
    else
        echo "Error: not found $DISTRO_BACKUP"
        echo "Tips: to build distro, run $0 build"
	exit
    fi
}

fix_audio() {
    echo "Fixing audio ..."
    sed -i "s|load-module module-sles-sink|#load-module module-sles-sink|g" $PREFIX/etc/pulse/default.pa
    sed -i "s|#load-module module-aaudio-sink|load-module module-aaudio-sink|g" $PREFIX/etc/pulse/default.pa
    echo "Done. Exit termux completely and start again to make it take effect."
}

fix_signal9() {
    echo "Run below commands with adb shell to fix singal9 "
    echo "device_config set_sync_disabled_for_tests persistent" 
    echo "device_config put activity_manager max_phantom_processes 2147483647"
}

install_vscode() {
    echo "Installing vscode ..."
    git clone https://aur.archlinux.org/visual-studio-code-bin.git $PREFIX/tmp/vscode
    $DISTRO_LOGIN --shared-tmp --user $DISTRO_USER -- bash -c 'cd /tmp/vscode && makepkg -sri --noconfirm'
}

backup_profile() {
    if [ "$1" == "" ]; then
        DISTRO_PROFILE=$DISTRO_PROFILE_DIR/$DISTRO-profile.tar.gz
        TERMUX_PROFILE=$DISTRO_PROFILE_DIR/termux-profile.tar.gz
    else
        DISTRO_PROFILE=$DISTRO_PROFILE_DIR/$DISTRO-$1.tar.gz
        TERMUX_PROFILE=$DISTRO_PROFILE_DIR/termux-$1.tar.gz
    fi

    # Check if termux profile exists
    if [ -e $TERMUX_PROFILE ]; then
        echo "Skip backup existed $TERMUX_PROFILE"
    else
        echo "Backup termux profile to $TERMUX_PROFILE"
        tar -czf $TERMUX_PROFILE -C $HOME .*
    fi

    # Check if distro profile exists
    if [ -e $DISTRO_PROFILE ]; then
        echo "Skip backup existed $DISTRO_PROFILE"
    else
        echo "Backup $DISTRO profile to $DISTRO_PROFILE"
        tar -czf $DISTRO_PROFILE -C $DISTRO_USER_HOME .config .vscode 
    fi
}

restore_profile() {
    if [ "$1" == "" ]; then
        DISTRO_PROFILE=$DISTRO_PROFILE_DIR/$DISTRO-profile.tar.gz
    else
        DISTRO_PROFILE=$DISTRO_PROFILE_DIR/$DISTRO-$1.tar.gz
    fi

    # Check if distro profile exists
    if [ -e $DISTRO_PROFILE ]; then
        echo "Restore user profile from $DISTRO_PROFILE"
        tar -xzvf $DISTRO_PROFILE -C $DISTRO_USER_HOME 
    else
        echo "Skipped! Not found $DISTRO_PROFILE"
    fi
}

restore_termux() {
    if [ "$1" == "" ]; then
        TERMUX_PROFILE=$DISTRO_PROFILE_DIR/termux-profile.tar.gz
    else
        TERMUX_PROFILE=$DISTRO_PROFILE_DIR/termux-$1.tar.gz
    fi

    # Check if termux profile exists
    if [ -e $TERMUX_PROFILE ]; then
        echo "Restore termux profile from $TERMUX_PROFILE"
        tar -xzf $TERMUX_PROFILE -C $HOME
    else
        echo "Skipped! Not found $TERMUX_PROFILE"
    fi
}

# Check the first command line argument
case "$1" in
  start|x11)
    start_x11 
    ;;
  build)
    build $2
    ;;
  reset)
    proot-distro remove $DISTRO
    restore_distro
    ;;
  *)
    [ "$1" == "" ] && start_x11
    COMMAND=$1
    shift
    echo "Run command $COMMAND $@"
    $COMMAND $@
    ;;
esac

