# install software
install_wps() {
    URL="http://software.openkylin.top/openkylin/yangtze/pool/all/wps-office_11.8.2.1116.AK.preload.sw.withsn_arm64.deb"
    [ ! -f "$TMPDIR/wps.deb" ] && curl --retry 5 -Lo $TMPDIR/wps.deb $URL
    $DISTRO_LOGIN -- apt install -f /tmp/wps.deb
}

# post setup after installation
setup_wps() {
    echo "Skip."
}

