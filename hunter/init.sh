# init apps_install
apps_install=""

# load apps functions and append apps to apps_install
for filename in $(ls -1 $SCRIPT_DIR/$DISTRO/[0-9]*.sh); do
    source "$filename"
    extracted=$(echo "$filename" | awk -F'[_.]' '{print $2}')
    apps_install+="$extracted "
done

# setup proot-distro
ln -sf $SCRIPT_DIR/hunter/proot-distro/hunter.sh $PREFIX/etc/proot-distro/hunter.sh

# init setup for distribution
init_distro() {
    # setup repo and sync
    PKGS="man sudo wget vim"
    echo "Initializing distribution ..."
    $DISTRO_LOGIN -- bash -c "mv /usr/sbin/telinit /usr/sbin/telinit.bak && ln -s /usr/bin/true /usr/sbin/telinit"
    $DISTRO_LOGIN -- sed -i "s|http://http.kali.org|http://mirrors.bfsu.edu.cn|g" /etc/apt/sources.list
    $DISTRO_LOGIN -- bash -c "DEBIAN_FRONTEND=noninteractive apt update && apt upgrade -y"
    $DISTRO_LOGIN -- bash -c "DEBIAN_FRONTEND=noninteractive apt install -y $PKGS"
}

# clean up distro
cleanup_distro() {
    $DISTRO_LOGIN -- bash -c "apt autoremove -y && apt clean"
}
