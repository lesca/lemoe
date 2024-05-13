# install software
install_sys() {
    PKGS="xfce4 xfce4-goodies pavucontrol"
    $DISTRO_LOGIN -- bash -c "DEBIAN_FRONTEND=noninteractive apt install -y $PKGS"

    # remove power manager
    $DISTRO_LOGIN -- apt remove -y --purge xfce4-power-manager xfce4-screensaver

    # set timezone 
    $DISTRO_LOGIN -- ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime 
}
