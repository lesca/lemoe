# install software
install_debtap() {
    git clone https://aur.archlinux.org/debtap.git $PREFIX/tmp/debtap
    $DISTRO_LOGIN --user $DISTRO_USER -- bash -c 'cd /tmp/debtap && makepkg -sri --noconfirm'

    #$DISTRO_LOGIN -- debtap -u
}
