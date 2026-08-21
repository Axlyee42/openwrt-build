#!/bin/sh
set -eu

VERSION="${1:?OpenWrt version required}"
FILES_DIR="${2:?ImageBuilder files directory required}"
RELEASE="${VERSION%.*}"
ARCH="x86_64"

mkdir -p "$FILES_DIR/etc/apk/keys" "$FILES_DIR/etc/apk/repositories.d"

# PassWall APK feed key and repositories (OpenWrt 25.12+).
curl -fL \
  'https://master.dl.sourceforge.net/project/openwrt-passwall-build/apk.pub' \
  -o "$FILES_DIR/etc/apk/keys/openwrt-passwall-build.pem"

cat > "$FILES_DIR/etc/apk/repositories.d/customfeeds.list" <<EOF
https://master.dl.sourceforge.net/project/openwrt-passwall-build/releases/packages-${RELEASE}/${ARCH}/passwall_luci/packages.adb
https://master.dl.sourceforge.net/project/openwrt-passwall-build/releases/packages-${RELEASE}/${ARCH}/passwall_packages/packages.adb
https://master.dl.sourceforge.net/project/openwrt-passwall-build/releases/packages-${RELEASE}/${ARCH}/passwall2/packages.adb
https://down.dllkids.xyz/openwrt-feed/daed/${RELEASE}/${ARCH}/packages.adb
EOF

# Keep a small helper in the firmware for installing the DAED feed/key later.
mkdir -p "$FILES_DIR/usr/libexec"
cat > "$FILES_DIR/usr/libexec/install-daede-feed.sh" <<'EOF'
#!/bin/sh
set -eu
wget -qO- https://down.dllkids.xyz/openwrt-feed/openwrt-feed-setup.sh | sh
apk update
apk add dae daed luci-app-daede
EOF
chmod 0755 "$FILES_DIR/usr/libexec/install-daede-feed.sh"
