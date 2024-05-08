#!/bin/bash

# Load user config
DISTRO_USER_CONFIG=$HOME/.lemoe
if [ ! -f "$DISTRO_USER_CONFIG" ]; then
    echo "DISTRO_USER=Lemoe" > $DISTRO_USER_CONFIG
fi
source $DISTRO_USER_CONFIG

# user parameters
BINDS=" --bind /storage/emulated/0/Documents:/media/documents"
BINDS=$BINDS" --bind /storage/emulated/0/Download:/media/downloads"

# system parameters
DISTRO=archlinux
SCRIPT_DIR=$(dirname $(realpath "$0"))
DISTRO_LOGIN="proot-distro login $DISTRO --shared-tmp $BINDS"
DISTRO_ROOTFS="$PREFIX/var/lib/proot-distro/installed-rootfs/$DISTRO"
DISTRO_BACKUP_DIR="$SCRIPT_DIR/distro_backup"
DISTRO_PROFILE_DIR="$SCRIPT_DIR/profile_backup"
DISTRO_USER_HOME=$DISTRO_ROOTFS/home/$DISTRO_USER

# source configurations
for file in $SCRIPT_DIR/$DISTRO/config/*.sh; do
    if [ -f "$file" ]; then
        source "$file"
    fi
done

# source distribution functions
for file in $SCRIPT_DIR/$DISTRO/*.sh; do
    if [ -f "$file" ]; then
        source "$file"
    fi
done

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

