install_fonts() {
    PKGS="fonts-recommended fonts-wqy-* fonts-lxgw-* fonts-cwtex-*"
    $DISTRO_LOGIN -- bash -c "DEBIAN_FRONTEND=noninteractive apt install -y $PKGS"
}
