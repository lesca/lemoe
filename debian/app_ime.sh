# install software
install_ime() {
    PKGS="fcitx5 fcitx5-chinese-addons fcitx5-material-color"
    $DISTRO_LOGIN -- apt install -y $PKGS
}

# post setup after installation
setup_ime() {
    # export to environment
    if ! grep -q "XMODIFIERS" $DISTRO_ROOTFS/etc/environment; then
        echo "GTK_IM_MODULE=fcitx" >> $DISTRO_ROOTFS/etc/environment
        echo "QT_IM_MODULE=fcitx" >> $DISTRO_ROOTFS/etc/environment
        echo "XMODIFIERS=@im=fcitx" >> $DISTRO_ROOTFS/etc/environment
    fi
}

# post user setup after installation
setup_user_ime() {
    # auto start
    $DISTRO_LOGIN --user $DISTRO_USER -- bash -c "mkdir -p ~/.config/autostart && cp /usr/share/applications/org.fcitx.Fcitx5.desktop ~/.config/autostart"
}
