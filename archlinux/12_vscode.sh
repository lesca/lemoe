# install offical version of vscode from AUR
install_vscode() {
    # install vscode, if not installed yet
    if [ -e $DISTRO_ROOTFS/usr/share/applications/code.desktop ]; then
        echo "VS Cdoe already installed. Skip."
        return
    fi

    $DISTRO_LOGIN --user $DISTRO_USER -- yay --noconfirm -S visual-studio-code-bin

    # setup shortcut
    sed -i "s|Exec=/usr/bin/code|Exec=/usr/bin/code --no-sandbox|g" \
        $DISTRO_ROOTFS/usr/share/applications/code.desktop
}
