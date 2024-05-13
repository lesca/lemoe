#!/bin/bash

# init
SCRIPT_DIR=$(dirname $(realpath "$0"))
source $SCRIPT_DIR/main/init.sh

# Load user config
DISTRO_USER_CONFIG=$HOME/.lemoe
config load
touch $TMPDIR/devices

# user parameters
BINDS=""
BINDS=$BINDS" --bind /storage/emulated/0/Documents:/media/documents"
BINDS=$BINDS" --bind /storage/emulated/0/Download:/media/downloads"
BINDS=$BINDS" --bind $TMPDIR/devices:$DISTRO_ROOTFS/proc/bus/pci/devices"

# system parameters
[ "$DISTRO" == "" ] && DISTRO=debian
DISTRO_LOGIN="proot-distro login $DISTRO --shared-tmp $BINDS"
DISTRO_ROOTFS="$PREFIX/var/lib/proot-distro/installed-rootfs/$DISTRO"
DISTRO_BACKUP_DIR="$SCRIPT_DIR/backups"
DISTRO_USER_HOME=$DISTRO_ROOTFS/home/$DISTRO_USER

# source functions
for file in $SCRIPT_DIR/main/*.sh $SCRIPT_DIR/$DISTRO/config/*.sh $SCRIPT_DIR/$DISTRO/*.sh; do
    if [ -f "$file" ]; then
        source "$file"
    fi
done

# Check the first command line argument
case "$1" in
  start|x11)
    start_x11
    ;;
  backup)
    backup_distro
    backup_profile
    ;;
  restore)
    proot-distro remove $DISTRO
    precheck
    ;;
  reset)
    proot-distro remove $DISTRO
    ;;
  *)
    [ "$1" == "" ] && start_x11
    COMMAND=$1
    shift
    # echo "Run command: $COMMAND $@"
    $COMMAND $@
    ;;
esac

