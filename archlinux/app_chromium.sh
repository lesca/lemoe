# install software
install_chromium() {
    PKGS="chromium"
    $DISTRO_LOGIN -- pacman -S --noconfirm $PKGS
}

# post setup after installation
setup_chromium() {
    sed -i "s|Exec=/usr/bin/chromium|Exec=/usr/bin/chromium --no-sandbox|g" \
        $DISTRO_ROOTFS/usr/share/applications/chromium.desktop
}