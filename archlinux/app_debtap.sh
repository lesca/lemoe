# install software
install_debtap() {
    git clone https://aur.archlinux.org/debtap.git $PREFIX/tmp/debtap
    $DISTRO_LOGIN --shared-tmp --user $DISTRO_USER -- bash -c 'cd /tmp/debtap && makepkg -sri --noconfirm'
}

# post setup after installation
setup_debtap() {
    echo "Skip."
    #$DISTRO_LOGIN -- debtap -u
}
