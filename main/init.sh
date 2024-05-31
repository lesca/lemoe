#!/bin/bash

config() {
    # config file is .lemoe
    if [ ! -f "$DISTRO_USER_CONFIG" ]; then
        echo "Create config file $DISTRO_USER_CONFIG"
        echo "DISTRO_USER=Lemoe" > $DISTRO_USER_CONFIG
        echo "DISTRO=debian" >> $DISTRO_USER_CONFIG
        echo "DISTRO_DPI=200" >> $DISTRO_USER_CONFIG
    fi

    case "$1" in
      load)
        source $DISTRO_USER_CONFIG
        ;;
      user)
        [ "$2" != "" ] && DISTRO_USER=$2 || return 
        grep -q "DISTRO_USER=" $DISTRO_USER_CONFIG \
            && sed -i "s|DISTRO_USER=.*$|DISTRO_USER=$2|g" $DISTRO_USER_CONFIG \
            || echo "DISTRO_USER=$2" >> $DISTRO_USER_CONFIG
        ;;
      distro)
        [ "$2" != "" ] && DISTRO=$2 || return
        grep -q "DISTRO=" $DISTRO_USER_CONFIG \
            && sed -i "s|DISTRO=.*$|DISTRO=$2|g" $DISTRO_USER_CONFIG \
            || echo "DISTRO=$2" >> $DISTRO_USER_CONFIG
        ;;
      dpi)
        [ "$2" != "" ] && DISTRO_DPI=$2 || return
        grep -q "DISTRO_DPI=" $DISTRO_USER_CONFIG \
            && sed -i "s|DISTRO_DPI=.*$|DISTRO_DPI=$2|g" $DISTRO_USER_CONFIG \
            || echo "DISTRO_DPI=$2" >> $DISTRO_USER_CONFIG
        ;;
      *)
        cat $DISTRO_USER_CONFIG
        ;;
    esac
}

