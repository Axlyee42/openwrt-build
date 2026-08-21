#!/bin/sh
set -eu

VERSION="${1:?OpenWrt version required}"
IMAGEBUILDER_DIR="${2:?ImageBuilder directory required}"
FILES_DIR="${3:?ImageBuilder files directory required}"
RELEASE="${VERSION%.*}"
ARCH="x86_64"

# OpenWrt 25.12 ImageBuilder uses this repositories file during package
# installation. /etc/apk is for the resulting firmware.
BUILDER_KEY_DIR="$IMAGEBUILDER_DIR/keys"
BUILDER_REPOSITORIES="$IMAGEBUILDER_DIR/repositories"
TARGET_KEY_DIR="$FILES_DIR/etc/apk/keys"
TARGET_REPO_DIR="$FILES_DIR/etc/apk/repositories.d"

mkdir -p "$BUILDER_KEY_DIR" "$TARGET_KEY_DIR" "$TARGET_REPO_DIR"

PASSWALL_KEY_URL='https://master.dl.sourceforge.net/project/openwrt-passwall-build/apk.pub'
PASSWALL_KEY="$BUILDER_KEY_DIR/openwrt-passwall-build.pem"
curl -fL "$PASSWALL_KEY_URL" -o "$PASSWALL_KEY"
cp -f "$PASSWALL_KEY" "$TARGET_KEY_DIR/openwrt-passwall-build.pem"

PASSWALL_BASE="https://master.dl.sourceforge.net/project/openwrt-passwall-build/releases/packages-${RELEASE}/${ARCH}"
DAED_BASE="https://down.dllkids.xyz/openwrt-feed/daed/${RELEASE}/${ARCH}"

# PassWall is installed from its signed remote APK repositories during the
# ImageBuilder run. DAED/DAE are supplied locally from wukongdaily APKs, so the
# DAED remote repository is deliberately NOT used during the build: its current
# signing key is intended to be installed by the runtime setup script and the
# feed otherwise causes ImageBuilder to reject the repository as untrusted.
printf '\n# Custom OpenWrt Build feeds\n' >> "$BUILDER_REPOSITORIES"
printf '%s\n' \
  "${PASSWALL_BASE}/passwall_luci/packages.adb" \
  "${PASSWALL_BASE}/passwall_packages/packages.adb" \
  "${PASSWALL_BASE}/passwall2/packages.adb" >> "$BUILDER_REPOSITORIES"

cat > "$TARGET_REPO_DIR/customfeeds.list" <<EOF
${PASSWALL_BASE}/passwall_luci/packages.adb
${PASSWALL_BASE}/passwall_packages/packages.adb
${PASSWALL_BASE}/passwall2/packages.adb
${DAED_BASE}/packages.adb
EOF

# Keep the upstream DAED installer in the firmware for runtime recovery/update.
mkdir -p "$FILES_DIR/usr/libexec"
cat > "$FILES_DIR/usr/libexec/install-daede-feed.sh" <<'EOF'
#!/bin/sh
set -eu
wget -qO- https://down.dllkids.xyz/openwrt-feed/openwrt-feed-setup.sh | sh
apk update
apk add dae daed luci-app-daede
EOF
chmod 0755 "$FILES_DIR/usr/libexec/install-daede-feed.sh"
