# install software
install_yay() {
    # yay
    git clone https://aur.archlinux.org/yay-bin.git $PREFIX/tmp/yay
    $DISTRO_LOGIN --user $DISTRO_USER -- bash -c 'cd /tmp/yay && makepkg -sri --noconfirm'

    # init
    $DISTRO_LOGIN --user $DISTRO_USER -- yay -Sy
}
