
setup_termux() {
    PKGS="git vim zip rsync proot-distro termux-x11-nightly pulseaudio"

    echo "Setting up termux ..."

    # Create dirs
    mkdir -p $DISTRO_BACKUP_DIR

    # Restore termux user profile
    if [ ! -f $HOME/.config ]; then
        restore_termux
    fi

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
    for app in $apps_install; do
        echo "Installing $app ..."
        install_cmd="install_$app"
        $install_cmd
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
    for app in $apps_install; do
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

    # backup distro
    rm -f $DISTRO_BACKUP_DIR/$DISTRO-base-0.tar.gz
    rm -f $DISTRO_BACKUP_DIR/$DISTRO-profile-0.tar.gz
    backup_distro 0
    backup_profile 0
}

precheck() {
    # ensure proot-distro is installed
    if [ $(dpkg --list | grep proot-distro | wc -l) -eq 0 ]; then
        setup_termux
    fi

    # ensure proot image from backup
    if [ ! -d "$DISTRO_ROOTFS" ]; then
        restore_distro
    fi

    # setup distro user profile and apps if not exist
    if [ ! -d $DISTRO_ROOTFS/home/$DISTRO_USER ] ; then
        setup_distro_user
        setup_user_apps
    fi
}

login() {
    [ "$1" == "" ] && LOGIN_PARAM="" || LOGIN_PARAM="--user $1"
    precheck 
    $DISTRO_LOGIN $LOGIN_PARAM
}

start_x11() {
    X11_ARGS="DISPLAY=:1 QT_FONT_DPI=$DISTRO_DPI"
    echo "Starting x11 for $DISTRO ..."
    precheck
    pulseaudio --start --exit-idle-time=-1 --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1"
    am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity
    $DISTRO_LOGIN --user $DISTRO_USER -- termux-x11 :1 -dpi $DISTRO_DPI -xstartup "$X11_ARGS dbus-launch --exit-with-session startxfce4"

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
        DISTRO_BACKUP=$DISTRO_BACKUP_DIR/$DISTRO-base-$1.tar.gz
    fi
    echo "Backup $DISTRO image to $DISTRO_BACKUP"
    proot-distro backup $DISTRO --output $DISTRO_BACKUP
}

restore_distro() {
    # Specify distro backup name
    if [ "$1" == "" ]; then
        DISTRO_BACKUP=$DISTRO_BACKUP_DIR/$DISTRO-base.tar.gz
    else
        DISTRO_BACKUP=$DISTRO_BACKUP_DIR/$DISTRO-base-$1.tar.gz
    fi

    # check distro backup file
    if [ ! -e "$DISTRO_BACKUP" ]; then
        echo "Error: not found $DISTRO_BACKUP"
        echo "Tips: to build distro, run $0 build"
        exit
    fi

    # reset distro
    if [ -d $DISTRO_ROOTFS ]; then
        echo "Resetting existing distro $DISTRO"
        proot-distro remove $DISTRO
    fi

    # restore distro
    echo "Restore $DISTRO image from $DISTRO_BACKUP"
    proot-distro restore $DISTRO_BACKUP

    # restore distro profile if using base image
    if [ "$1" == "" ]; then
        restore_profile
    fi
}

backup_profile() {
    NOW=$(date '+%Y%m%d-%H%M%S')
    if [ "$1" == "" ]; then
        DISTRO_PROFILE=$DISTRO_BACKUP_DIR/$DISTRO-profile-$NOW.tar.gz
    else
        DISTRO_PROFILE=$DISTRO_BACKUP_DIR/$DISTRO-profile-$1.tar.gz
    fi

    # Check if distro profile exists
    echo "Backup $DISTRO profile to $DISTRO_PROFILE"
    if [ -e $DISTRO_PROFILE ]; then
        echo "Skip backup existed $DISTRO_PROFILE"
    else
        pushd $DISTRO_USER_HOME > /dev/null
        tar -czf $DISTRO_PROFILE --exclude=".gnupg" --exclude=".cache" --exclude=".dbus" .*
        popd > /dev/null
    fi
}

backup_termux() {
    NOW=$(date '+%Y%m%d-%H%M%S')
    if [ "$1" == "" ]; then
        TERMUX_PROFILE=$DISTRO_BACKUP_DIR/termux-profile-$NOW.tar.gz
    else
        TERMUX_PROFILE=$DISTRO_BACKUP_DIR/termux-profile-$1.tar.gz
    fi

    # Check if termux profile exists
    echo "Backup termux profile to $TERMUX_PROFILE"
    if [ -e $TERMUX_PROFILE ]; then
        echo "Skip backup existed $TERMUX_PROFILE"
    else
        pushd $HOME > /dev/null
        tar -czf $TERMUX_PROFILE --exclude=".bash_history" --exclude=".cache" --exclude=".timerdir" .*
        popd > /dev/null
    fi
}

restore_profile() {
    if [ "$1" == "" ]; then
        DISTRO_PROFILE=$DISTRO_BACKUP_DIR/$DISTRO-profile.tar.gz
    else
        DISTRO_PROFILE=$DISTRO_BACKUP_DIR/$DISTRO-profile-$1.tar.gz
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
        TERMUX_PROFILE=$DISTRO_BACKUP_DIR/termux-profile.tar.gz
    else
        TERMUX_PROFILE=$DISTRO_BACKUP_DIR/termux-profile-$1.tar.gz
    fi

    # Check if termux profile exists
    if [ -e $TERMUX_PROFILE ]; then
        echo "Restore termux profile from $TERMUX_PROFILE"
        tar -xzf $TERMUX_PROFILE -C $HOME
    else
        echo "Skipped! Not found $TERMUX_PROFILE"
    fi
}

lazypack() {
    # init vars
    NOW=$(date '+%Y%m%d-%H%M%S')
    LAZY_PACKS_DIR=$SCRIPT_DIR/../lazy-packs-lemoe
    mkdir -p $LAZY_PACKS_DIR

    echo "Saving current project to $LAZY_PACKS_DIR/lemoe-$DISTRO-$NOW.zip ..." 
    
    # remove old lazy pack project directory
    rm -rf $LAZY_PACKS_DIR/lemoe

    # copy project files and ditro backups
    rsync -a --delete --exclude='.git' \
        --exclude='packages' \
        --include="backups/$DISTRO-base.tar.gz" \
        --include="backups/$DISTRO-profile.tar.gz" \
        --exclude='backups/*.tar.gz' \
        $SCRIPT_DIR $LAZY_PACKS_DIR

    # zip the lazy pack
    pushd $LAZY_PACKS_DIR > /dev/null
    zip -0 -r "lemoe-$DISTRO-$NOW.zip" lemoe
    popd > /dev/null

    # Finished
    echo "Finished."
}
