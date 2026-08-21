#!/bin/sh
set -eux

# Prepare PassWall APK feed for OpenWrt 25.12+
# This only adds the official PassWall APK key and repository.
# Package selection remains in apk-custom-packages.sh.

TARGET_DIR="${1:-files}"

mkdir -p "${TARGET_DIR}/etc/apk/keys"
mkdir -p "${TARGET_DIR}/etc/apk/repositories.d"

wget -O "${TARGET_DIR}/etc/apk/keys/openwrt-passwall-build.pem" \
  https://master.dl.sourceforge.net/project/openwrt-passwall-build/apk.pub

release="${OPENWRT_VERSION%.*}"
arch="x86_64"

cat > "${TARGET_DIR}/etc/apk/repositories.d/passwall.list" <<EOF
https://master.dl.sourceforge.net/project/openwrt-passwall-build/releases/packages-${release}/${arch}/passwall_luci/packages.adb
https://master.dl.sourceforge.net/project/openwrt-passwall-build/releases/packages-${release}/${arch}/passwall_packages/packages.adb
https://master.dl.sourceforge.net/project/openwrt-passwall-build/releases/packages-${release}/${arch}/passwall2/packages.adb
EOF

cat "${TARGET_DIR}/etc/apk/repositories.d/passwall.list"
