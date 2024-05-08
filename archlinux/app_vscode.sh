# install offical version of vscode from AUR
install_vscode() {
    # install vscode, if not installed yet
    if [ -e $DISTRO_ROOTFS/usr/share/applications/code.desktop ]; then
        echo "VS Cdoe already installed. Skip."
        return
    fi

    git clone https://aur.archlinux.org/visual-studio-code-bin.git $PREFIX/tmp/vscode
    $DISTRO_LOGIN --shared-tmp --user $DISTRO_USER -- bash -c 'cd /tmp/vscode && makepkg -sri --noconfirm'
}

# post setup after installation
setup_vscode() {
    sed -i "s|Exec=/usr/bin/code|Exec=/usr/bin/code --no-sandbox|g" \
        $DISTRO_ROOTFS/usr/share/applications/code.desktop
}