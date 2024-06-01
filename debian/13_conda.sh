
install_conda() {
    # download installation script
    URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh"
    INSTALL_SCRIPT=$TMPDIR/conda-install.sh
    if [ ! -e $INSTALL_SCRIPT ]; then
        curl --retry 5 -Lo $INSTALL_SCRIPT $URL
    fi

    # install
    $DISTRO_LOGIN -- bash $INSTALL_SCRIPT -b -f -p /usr/share/miniconda
}

# user
setup_user_conda() {
    $DISTRO_LOGIN --user $DISTRO_USER -- /usr/share/miniconda/bin/conda init 
    $DISTRO_LOGIN --user $DISTRO_USER -- /usr/share/miniconda/bin/conda config --set auto_activate_base false
}

remove_conda() {
    $DISTRO_LOGIN --user $DISTRO_USER -- /usr/share/miniconda/bin/conda init --reset
    $DISTRO_LOGIN -- rm -rf /usrs/share/miniconda
}
