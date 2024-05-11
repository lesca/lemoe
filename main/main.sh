
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
        grep -q "https://packages-cf.termux.org" $PREFIX/etc/apt/sources.list && termux-change-repo
        pkg update -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
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
    echo "Installing distro $DISTRO ..."

    # proot-distro install if not exists
    if [ ! -d "$DISTRO_ROOTFS" ]; then
        proot-distro install $DISTRO
    fi

    # init setup for distribution
    init_distro

    # create distro user profile
    setup_distro_user

    # install apps
    for app in "${apps_install[@]}"; do
        echo "Installing $app ..."
        install_cmd="install_$app"
        $install_cmd

        echo "Post setup $app ..."
        setup_cmd="setup_$app"
        $setup_cmd
    done

    # setup distro user apps
    setup_user_apps

    # cleanup distro
    cleanup_distro

    # finished
    echo "Finished."

}

setup_distro_user() {
    # setup user
    ETC="$DISTRO_ROOTFS/etc"
    LINE="$DISTRO_USER ALL=(ALL:ALL) NOPASSWD: ALL"
    FILE="$ETC/sudoers.d/$DISTRO"

    echo "Setting up distro user $DISTRO_USER ..."

    # create a new user
    $DISTRO_LOGIN -- useradd -m -G root -s /bin/bash $DISTRO_USER

    # enable sudo for this user
    touch $FILE
    if ! grep -q "$LINE" $FILE; then
        echo "$LINE" >> $FILE
    fi
}

setup_user_apps() {
    # user apps post setup
    for app in "${apps_install[@]}"; do
        if declare -F | grep -q " setup_user_$app$"; then
            echo "Post setup $app for user $DISTRO_USER ..."
            setup_cmd="setup_user_$app"
            $setup_cmd
        fi
    done
}

build() {
    if [ ! "$1" == "" ]; then
        config distro $1
        echo "DISTRO is set to $DISTRO, run 'bash lemoe.sh build' to build image."
        exit
    fi


    # Display the value of DISTRO_USER
    echo "DISTRO is set to: $DISTRO"

    # build distro
    setup_termux
    install_distro
}

config() {
    # config file is .lemoe
    if [ ! -f "$DISTRO_USER_CONFIG" ]; then
        echo "DISTRO_USER=Lemoe" > $DISTRO_USER_CONFIG
        echo "DISTRO=debian" >> $DISTRO_USER_CONFIG
    fi

    if [ "$2" == "" ]; then
        echo "Empty parameter. Skip."
        return
    fi

    case "$1" in
      user)
        DISTRO_USER=$2
        grep -q "DISTRO_USER=" $DISTRO_USER_CONFIG \
            && sed -i "s|DISTRO_USER=.*$|DISTRO_USER=$2|g" $DISTRO_USER_CONFIG \
            || echo "DISTRO_USER=$2" >> $DISTRO_USER_CONFIG
        ;;
      distro)
        DISTRO=$2
        grep -q "DISTRO=" $DISTRO_USER_CONFIG \
            && sed -i "s|DISTRO=.*$|DISTRO=$2|g" $DISTRO_USER_CONFIG \
            || echo "DISTRO=$2" >> $DISTRO_USER_CONFIG
        ;;
      *)
        echo "Invalid config parameter $1"
        ;;
    esac
}

precheck() {
    # ensure proot-distro is installed
    if [ $(dpkg --list | grep proot-distro | wc -l) -eq 0 ]; then
        setup_termux
    fi

    # ensure proot image from backup
    if [ ! -d "$DISTRO_ROOTFS" ]; then
        restore_distro
        FLAG_NEED_RESTORE=1
    fi

    # setup distro user profile and apps if not exist
    if [ ! -d $DISTRO_ROOTFS/home/$DISTRO_USER ] ; then
        setup_distro_user
        setup_user_apps
    fi

    # restore user profile if image was restored
    if [ ! -z "$FLAG_NEED_RESTORE" ]; then
        restore_profile
    fi

}

login() {
    [ "$1" == "" ] && LOGIN_PARAM="" || LOGIN_PARAM="--user $1"
    precheck 
    $DISTRO_LOGIN $LOGIN_PARAM
}

start_x11() {
    echo "Starting x11 for $DISTRO ..."
    precheck
    pulseaudio --start --exit-idle-time=-1 --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1"
    am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity
    $DISTRO_LOGIN --user $DISTRO_USER -- termux-x11 :1 -xstartup "dbus-launch --exit-with-session startxfce4"

    # clean up
    echo "Cleaning up ..."
    killall -9 pulseaudio 2>/dev/null
    echo "Done."
    exit
}

backup_distro() {
    # Specify distro backup name
    NOW=$(date '+%Y%m%d-%H%M%S')
    if [ "$1" == "" ]; then
        DISTRO_BACKUP=$DISTRO_BACKUP_DIR/$DISTRO-base-$NOW.tar.gz
    else
        DISTRO_BACKUP=$DISTRO_BACKUP_DIR/$DISTRO-$1-$NOW.tar.gz
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

    # restore distro from backup
    echo "Restore $DISTRO image from $DISTRO_BACKUP"
    if [ -e "$DISTRO_BACKUP" ]; then
        proot-distro restore $DISTRO_BACKUP
    else
        echo "Error: not found $DISTRO_BACKUP"
        echo "Tips: to build distro, run $0 build"
	exit
    fi
}

backup_profile() {
    NOW=$(date '+%Y%m%d-%H%M%S')
    if [ "$1" == "" ]; then
        DISTRO_PROFILE=$DISTRO_PROFILE_DIR/$DISTRO-profile-$NOW.tar.gz
        TERMUX_PROFILE=$DISTRO_PROFILE_DIR/termux-profile-$NOW.tar.gz
    else
        DISTRO_PROFILE=$DISTRO_PROFILE_DIR/$DISTRO-$1-$NOW.tar.gz
        TERMUX_PROFILE=$DISTRO_PROFILE_DIR/termux-$1-$NOW.tar.gz
    fi

    # Check if termux profile exists
    if [ -e $TERMUX_PROFILE ]; then
        echo "Skip backup existed $TERMUX_PROFILE"
    else
        echo "Backup termux profile to $TERMUX_PROFILE"
        pushd $HOME
        tar -czf $TERMUX_PROFILE .*
        popd
    fi

    # Check if distro profile exists
    if [ -e $DISTRO_PROFILE ]; then
        echo "Skip backup existed $DISTRO_PROFILE"
    else
        echo "Backup $DISTRO profile to $DISTRO_PROFILE"
        pushd $DISTRO_USER_HOME
        tar -czf $DISTRO_PROFILE --exclude=".gnupg" --exclude=".cache" --exclude=".dbus" .*
        popd
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
        tar -xzf $DISTRO_PROFILE -C $DISTRO_USER_HOME 
    else
        echo "Skipped restoring user profile. Not found $DISTRO_PROFILE"
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
