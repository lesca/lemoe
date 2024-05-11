#!/bin/bash

config() {
    # config file is .lemoe
    if [ ! -f "$DISTRO_USER_CONFIG" ]; then
        echo "Create config file ~/.lemoe"
        echo "DISTRO_USER=Lemoe" > $DISTRO_USER_CONFIG
        echo "DISTRO=debian" >> $DISTRO_USER_CONFIG
        echo "DISTRO_DPI=200" >> $DISTRO_USER_CONFIG
    fi

    # load config
    if [ "$1" == "load" ]; then
        source $DISTRO_USER_CONFIG
    fi

    # other commands require parameters
    if [ "$2" == "" ]; then
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
      dpi)
        DISTRO_DPI=$2
        grep -q "DISTRO_DPI=" $DISTRO_USER_CONFIG \
            && sed -i "s|DISTRO_DPI=.*$|DISTRO_DPI=$2|g" $DISTRO_USER_CONFIG \
            || echo "DISTRO_DPI=$2" >> $DISTRO_USER_CONFIG
        ;;
      *)
        echo "Invalid config parameter $1"
        ;;
    esac
}

