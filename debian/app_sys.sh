# install software
install_sys() {
    PKGS_XFCE4="xfce4 xfce4-goodies pavucontrol"
    PKGS_FONTS="ttf-wqy-microhei ttf-wqy-zenhei xfonts-wqy"

    $DISTRO_LOGIN -- bash -c "DEBIAN_FRONTEND=noninteractive apt install -y $PKGS_XFCE4 $PKGS_FONTS"
}

# post setup after installation
setup_sys() {
    # remove power manager
    $DISTRO_LOGIN -- apt remove -y --purge xfce4-power-manager xfce4-screensaver
    $DISTRO_LOGIN -- apt autoremove -y

    # set timezone 
    $DISTRO_LOGIN -- ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime 
}
