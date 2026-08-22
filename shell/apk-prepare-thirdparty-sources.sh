#!/bin/bash
set -e

IMAGE_FILES_DIR="${FILES_DIR:-${IMAGEBUILDER_DIR:-$(pwd)}/files}"
APK_DIR="$IMAGE_FILES_DIR/etc/apk/repositories.d"
KEY_DIR="$IMAGE_FILES_DIR/etc/apk/keys"

mkdir -p "$APK_DIR" "$KEY_DIR"

# PassWall APK feed
cat > "$APK_DIR/passwall.list" <<'EOF'
https://master.dl.sourceforge.net/project/openwrt-passwall-build/releases/packages-25.12/x86_64/passwall_luci/packages.adb
https://master.dl.sourceforge.net/project/openwrt-passwall-build/releases/packages-25.12/x86_64/passwall_packages/packages.adb
https://master.dl.sourceforge.net/project/openwrt-passwall-build/releases/packages-25.12/x86_64/passwall2/packages.adb
EOF

# Aurora official APK feed
cat > "$APK_DIR/aurora.list" <<'EOF'
https://openwrt.eamonxg.fun/packages/packages.adb
EOF

# kenzok8 openwrt-daede source installer
cat > "$IMAGE_FILES_DIR/etc/uci-defaults/100-daede-source" <<'EOF'
#!/bin/sh
mkdir -p /etc/apk/repositories.d

# kenzok8/openwrt-daede provides dae, daed and luci-app-daede.
# Keep the installer method here because the feed URL/key may change upstream.
wget -O /tmp/daede-feed-setup.sh https://raw.githubusercontent.com/kenzok8/openwrt-daede/main/scripts/install.sh 2>/dev/null || true

if [ -s /tmp/daede-feed-setup.sh ]; then
    chmod +x /tmp/daede-feed-setup.sh
    /tmp/daede-feed-setup.sh || true
fi

exit 0
EOF

# PassWall public key installation on first boot
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
chmod +x "$IMAGE_FILES_DIR/etc/uci-defaults/100-daede-source"
