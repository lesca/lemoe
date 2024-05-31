# install software
install_sys() {
    PKGS="xfce4 xfce4-goodies pavucontrol kali-menu"
    $DISTRO_LOGIN -- bash -c "DEBIAN_FRONTEND=noninteractive apt install -y $PKGS"

    # remove power manager
    $DISTRO_LOGIN -- apt remove -y --purge xfce4-power-manager xfce4-screensaver

    # set timezone 
    $DISTRO_LOGIN -- ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime 
}

setup_user_sys() {
    $DISTRO_LOGIN --user $DISTRO_USER -- bash -c 'touch ~/.hushlogin'
}
