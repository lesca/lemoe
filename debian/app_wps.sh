# install software
install_wps() {
    PKG="wps-office_11.8.2.1116.AK.preload.sw.withsn_arm64.deb"
    PKGS_DIR=$SCRIPT_DIR/../packages
    URL="http://software.openkylin.top/openkylin/yangtze/pool/all/$PKG"
    [ -f "$PKGS_DIR/$PKG" ] && cp $PKGS_DIR/$PKG $TMPDIR || curl --retry 5 -Lo $TMPDIR/$PKG $URL
    [ -f "$TMPDIR/$PKG" ] && $DISTRO_LOGIN -- apt install -f $TMPDIR/$PKG
}
