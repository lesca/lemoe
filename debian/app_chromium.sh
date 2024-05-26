# install software
install_chromium() {
    PKGS="chromium"
    $DISTRO_LOGIN -- apt install -y $PKGS

    # setup chromium shortcut
    sed -i "s|Exec=/usr/bin/chromium|Exec=/usr/bin/chromium --no-sandbox|g" \
        $DISTRO_ROOTFS/usr/share/applications/chromium.desktop

    # set default browser
    $DISTRO_LOGIN -- xdg-mime default chromium.desktop x-scheme-handler/https
    $DISTRO_LOGIN -- xdg-mime default chromium.desktop x-scheme-handler/http
}
