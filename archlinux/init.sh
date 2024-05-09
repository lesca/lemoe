# init setup for distribution
init_distro() {
    PKGS="man sudo wget vim base-devel"
    # setup repo and sync
    $DISTRO_LOGIN -- sed -i "s|http://mirror.archlinuxarm.org|http://mirrors.bfsu.edu.cn/archlinuxarm|g" /etc/pacman.d/mirrorlist
    $DISTRO_LOGIN -- pacman -Syyu --noconfirm
    $DISTRO_LOGIN -- pacman -S --noconfirm $PKGS
}