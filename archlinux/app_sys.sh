# install software
install_sys() {
    PKGS_XFCE4="xfce4 xfce4-goodies pavucontrol"
    PKGS_FONTS="adobe-source-han-sans-cn-fonts adobe-source-han-serif-cn-fonts noto-fonts-cjk wqy-microhei wqy-microhei-lite wqy-bitmapfont wqy-zenhei ttf-arphic-ukai ttf-arphic-uming"

    $DISTRO_LOGIN -- pacman -S --noconfirm $PKGS_XFCE4 $PKGS_FONTS 
}

# post setup after installation
setup_sys() {
    # remove power manager
    $DISTRO_LOGIN -- pacman -R --noconfirm xfce4-power-manager xfce4-screensaver

    # set timezone 
    $DISTRO_LOGIN -- ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime 
}
