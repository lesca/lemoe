install_fonts() {
    PKGS="ttf-mscorefonts-installer"
    $DISTRO_LOGIN -- bash -c "DEBIAN_FRONTEND=noninteractive apt install -y $PKGS"
}

# post setup after installation
setup_fonts() {
    echo "Skip."
}
