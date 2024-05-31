# install software
install_tools() {
    PKGS="kali-tools-passwords kali-tools-crypto-stego kali-tools-fuzzing"
    $DISTRO_LOGIN -- bash -c "DEBIAN_FRONTEND=noninteractive apt install -y $PKGS"
}

