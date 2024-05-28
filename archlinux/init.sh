# init apps_install
apps_install=""

# load apps functions and append apps to apps_install
for filename in $(ls -1 $SCRIPT_DIR/$DISTRO/[0-9]*.sh); do
    source "$filename"
    extracted=$(echo "$filename" | awk -F'[_.]' '{print $2}')
    apps_install+="$extracted "
done
echo "Discovered apps: $apps_install"

# init setup for distribution
init_distro() {
    # setup repo and sync
    PKGS="man sudo wget vim base-devel"

    $DISTRO_LOGIN -- sed -i "s|http://mirror.archlinuxarm.org|http://mirrors.bfsu.edu.cn/archlinuxarm|g" /etc/pacman.d/mirrorlist
    $DISTRO_LOGIN -- pacman -Syyu --noconfirm
    $DISTRO_LOGIN -- pacman -S --noconfirm $PKGS
}

# clean up distro
cleanup_distro() {
    $DISTRO_LOGIN -- bash -c "yes | pacman -Scc"
}
