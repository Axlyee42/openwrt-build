#!/bin/bash
set -e

IMAGE_FILES_DIR="${FILES_DIR:-${IMAGEBUILDER_DIR:-$(pwd)}/files}"
APK_DIR="$IMAGE_FILES_DIR/etc/apk/repositories.d"
KEY_DIR="$IMAGE_FILES_DIR/etc/apk/keys"
UCI_DIR="$IMAGE_FILES_DIR/etc/uci-defaults"

mkdir -p "$APK_DIR" "$KEY_DIR" "$UCI_DIR"

# PassWall official APK repository (OpenWrt 25.12 x86_64)
cat > "$APK_DIR/passwall.list" <<'EOF'
https://master.dl.sourceforge.net/project/openwrt-passwall-build/releases/packages-25.12/x86_64/passwall_luci/packages.adb
https://master.dl.sourceforge.net/project/openwrt-passwall-build/releases/packages-25.12/x86_64/passwall_packages/packages.adb
https://master.dl.sourceforge.net/project/openwrt-passwall-build/releases/packages-25.12/x86_64/passwall2/packages.adb
EOF

# Aurora official APK repository
cat > "$APK_DIR/aurora.list" <<'EOF'
https://openwrt.eamonxg.fun/packages/x86_64/packages.adb
EOF

# Install PassWall repository key on first boot
cat > "$UCI_DIR/99-passwall-apk-key" <<'EOF'
#!/bin/sh
mkdir -p /etc/apk/keys
wget -O /etc/apk/keys/openwrt-passwall-build.pem \
https://master.dl.sourceforge.net/project/openwrt-passwall-build/apk.pub || true
chmod 600 /etc/apk/keys/openwrt-passwall-build.pem 2>/dev/null || true
exit 0
EOF

# Refresh package database after first boot
cat > "$UCI_DIR/98-thirdparty-apk-update" <<'EOF'
#!/bin/sh
apk update || true
exit 0
EOF

chmod +x "$UCI_DIR/98-thirdparty-apk-update"
chmod +x "$UCI_DIR/99-passwall-apk-key"
