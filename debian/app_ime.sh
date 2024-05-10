# install software
install_ime() {
    PKGS="fcitx5 fcitx5-chinese-addons fcitx5-material-color"
    $DISTRO_LOGIN -- apt install -y $PKGS
}

# post setup after installation
setup_ime() {
    echo "Skip."
}

# post user setup after installation
setup_user_ime() {
    # auto start
    $DISTRO_LOGIN --user $DISTRO_USER -- bash -c "mkdir -p ~/.config/autostart && cp /usr/share/applications/org.fcitx.Fcitx5.desktop ~/.config/autostart"
}
