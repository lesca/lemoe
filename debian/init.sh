# init setup for distribution
init_distro() {
    PKGS="man sudo wget vim"
    # setup repo and sync
    echo "Initializing distribution ..."
    $DISTRO_LOGIN -- sed -i "s|http://deb.debian.org|http://mirrors.bfsu.edu.cn|g" /etc/apt/sources.list
    $DISTRO_LOGIN -- sed -i "s|http://security.debian.org|http://mirrors.bfsu.edu.cn|g" /etc/apt/sources.list
    $DISTRO_LOGIN -- bash -c "apt update && apt upgrade -y"
    $DISTRO_LOGIN -- bash -c "DEBIAN_FRONTEND=noninteractive apt install -y $PKGS"
}

# clean up distro
cleanup_distro() {
    $DISTRO_LOGIN -- bash -c "apt clean"
}
