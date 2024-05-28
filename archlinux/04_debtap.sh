# install software
install_debtap() {
    $DISTRO_LOGIN --user $DISTRO_USER -- yay --noconfirm -S debtap
    #$DISTRO_LOGIN -- debtap -u
}
