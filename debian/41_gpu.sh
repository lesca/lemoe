# install software
install_gpu() {
    PKG="mesa-vulkan-kgsl_24.1.0-devel-20240120_arm64.deb"
    PKGS_DIR=$SCRIPT_DIR/packages
    [ -f "$PKGS_DIR/$PKG" ] && cp $PKGS_DIR/$PKG $TMPDIR
    [ -f "$TMPDIR/$PKG" ] && $DISTRO_LOGIN -- apt install -f $TMPDIR/$PKG

    # enable for chromium
    sed -i "s|Exec=/usr/bin/chromium|Exec=env MESA_LOADER_DRIVER_OVERRIDE=zink TU_DEBUG=noconform /usr/bin/chromium|g" \
        $DISTRO_ROOTFS/usr/share/applications/chromium.desktop
}

remove_gpu() {
    $DISTRO_LOGIN -- dpkg -r mesa-vulkan-drivers:arm64
}
