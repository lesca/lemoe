# install software
install_ime() {
    PKGS="fcitx5-im fcitx5-chinese-addons fcitx5-material-color"
    $DISTRO_LOGIN -- pacman -S --noconfirm $PKGS

    # export to environment
    if ! grep -q "XMODIFIERS" $DISTRO_ROOTFS/etc/environment; then
        echo "GTK_IM_MODULE=fcitx" >> $DISTRO_ROOTFS/etc/environment
        echo "QT_IM_MODULE=fcitx" >> $DISTRO_ROOTFS/etc/environment
        echo "XMODIFIERS=@im=fcitx" >> $DISTRO_ROOTFS/etc/environment
    fi
}
