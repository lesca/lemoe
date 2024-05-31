# This is a distribution plug-in.
DISTRO_NAME="Kali (nethunter)"
DISTRO_COMMENT="Stable release."

#TARBALL_URL['aarch64']="https://kali.download/nethunter-images/current/rootfs/kalifs-arm64-full.tar.xz"
#TARBALL_SHA256['aarch64']="651468e967485dad3ca2684ef62243bed8de8a1f0044dd3ecfd87bdc6e75d07c"
TARBALL_URL['aarch64']="https://kali.download/nethunter-images/current/rootfs/kalifs-arm64-minimal.tar.xz"
TARBALL_SHA256['aarch64']="c4d1d8be66c243d94ce21fd61ba5ab55bbd8fd5d105c1888402016864a6f0490"

distro_setup() {
    touch ./root/.hushlogin
    # fix libc6 upgrade issue
    # FILE=./var/lib/dpkg/info/libc6:arm64.postinst
    # if grep -q "^set -e" "$FILE"; then
    #     sed -i 's/^set -e/# set -e/' "$FILE"
    # fi
}

