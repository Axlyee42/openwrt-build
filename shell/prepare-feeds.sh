#!/bin/sh
set -eu

VERSION="${1:?OpenWrt version required}"
IMAGEBUILDER_DIR="${2:?ImageBuilder directory required}"
FILES_DIR="${3:?ImageBuilder files directory required}"
RELEASE="${VERSION%.*}"
ARCH="x86_64"

# OpenWrt 25.12 ImageBuilder uses these files at the ImageBuilder root for
# package installation. /etc/apk is for the resulting firmware only.
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

# Keep the ImageBuilder repository file in the format expected by apk v3.
# The stock repositories file is preserved and the custom feeds are appended.
printf '\n# Custom OpenWrt Build feeds\n' >> "$BUILDER_REPOSITORIES"
printf '%s\n' \
  "${PASSWALL_BASE}/passwall_luci/packages.adb" \
  "${PASSWALL_BASE}/passwall_packages/packages.adb" \
  "${PASSWALL_BASE}/passwall2/packages.adb" \
  "${DAED_BASE}/packages.adb" >> "$BUILDER_REPOSITORIES"

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
