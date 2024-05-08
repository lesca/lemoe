# install software
install_ime() {
    PKGS="fcitx5-im fcitx5-chinese-addons fcitx5-material-color"
    $DISTRO_LOGIN -- pacman -S --noconfirm $PKGS
}

# post setup after installation
setup_ime() {
    echo "TODO"
}