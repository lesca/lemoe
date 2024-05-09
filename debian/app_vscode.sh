# install 
install_vscode() {
    $DISTRO_LOGIN -- bash -c 'curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/microsoft.gpg'
    $DISTRO_LOGIN -- bash -c 'install -o root -g root -m 644 /tmp/microsoft.gpg /etc/apt/keyrings/microsoft-archive-keyring.gpg'
    $DISTRO_LOGIN -- bash -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
    $DISTRO_LOGIN -- bash -c 'apt update -y && apt install -y code'
}

# post setup after installation
setup_vscode() {
    sed -i "s|Exec=/usr/share/code/code|Exec=/usr/share/code/code --no-sandbox|g" \
        $DISTRO_ROOTFS/usr/share/applications/code.desktop
}
