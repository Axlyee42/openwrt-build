#!/bin/bash
set -e

IMAGE_FILES_DIR="${FILES_DIR:-${IMAGEBUILDER_DIR:-$(pwd)}/files}"
APK_DIR="$IMAGE_FILES_DIR/etc/apk/repositories.d"
KEY_DIR="$IMAGE_FILES_DIR/etc/apk/keys"

mkdir -p "$APK_DIR" "$KEY_DIR"

cat > "$APK_DIR/passwall.list" <<'EOF'
https://master.dl.sourceforge.net/project/openwrt-passwall-build/releases/packages-25.12/x86_64/passwall_luci/packages.adb
https://master.dl.sourceforge.net/project/openwrt-passwall-build/releases/packages-25.12/x86_64/passwall_packages/packages.adb
https://master.dl.sourceforge.net/project/openwrt-passwall-build/releases/packages-25.12/x86_64/passwall2/packages.adb
EOF

cat > "$APK_DIR/aurora.list" <<'EOF'
# luci-theme-aurora repository will be provided by the custom apk repository
EOF

# PassWall public key will be installed on first boot if required
cat > "$IMAGE_FILES_DIR/etc/uci-defaults/99-thirdparty-apk-sources" <<'EOF'
#!/bin/sh
mkdir -p /etc/apk/keys /etc/apk/repositories.d

wget -O /etc/apk/keys/openwrt-passwall-build.pem \
https://master.dl.sourceforge.net/project/openwrt-passwall-build/apk.pub || true

chmod 600 /etc/apk/keys/openwrt-passwall-build.pem 2>/dev/null || true

apk update || true

exit 0
EOF

chmod +x "$IMAGE_FILES_DIR/etc/uci-defaults/99-thirdparty-apk-sources"
