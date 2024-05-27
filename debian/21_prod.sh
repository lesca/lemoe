# install software
install_prod() {
    PKGS="xournalpp"
    $DISTRO_LOGIN -- apt install -y $PKGS
}

# post user setup after installation
setup_user_prod() {
    # auto start
    $DISTRO_LOGIN --user $DISTRO_USER -- bash -c "mkdir -p ~/.config/autostart && cp /usr/share/applications/org.fcitx.Fcitx5.desktop ~/.config/autostart"
}
