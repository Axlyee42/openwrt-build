#!/bin/sh
set -eu

VERSION="${1:?OpenWrt version required}"
IMAGEBUILDER_DIR="${2:?ImageBuilder directory required}"
FILES_DIR="${3:?ImageBuilder files directory required}"
RELEASE="${VERSION%.*}"
ARCH="x86_64"

BUILDER_APK_DIR="$IMAGEBUILDER_DIR/etc/apk"
BUILDER_KEY_DIR="$BUILDER_APK_DIR/keys"
BUILDER_REPO_DIR="$BUILDER_APK_DIR/repositories.d"
TARGET_KEY_DIR="$FILES_DIR/etc/apk/keys"
TARGET_REPO_DIR="$FILES_DIR/etc/apk/repositories.d"

mkdir -p "$BUILDER_KEY_DIR" "$BUILDER_REPO_DIR" "$TARGET_KEY_DIR" "$TARGET_REPO_DIR"

# PassWall: this feed is needed during ImageBuilder package installation.
PASSWALL_KEY_URL='https://master.dl.sourceforge.net/project/openwrt-passwall-build/apk.pub'
PASSWALL_KEY="$BUILDER_KEY_DIR/openwrt-passwall-build.pem"
curl -fL "$PASSWALL_KEY_URL" -o "$PASSWALL_KEY"
cp -f "$PASSWALL_KEY" "$TARGET_KEY_DIR/openwrt-passwall-build.pem"

PASSWALL_BASE="https://master.dl.sourceforge.net/project/openwrt-passwall-build/releases/packages-${RELEASE}/${ARCH}"
DAED_BASE="https://down.dllkids.xyz/openwrt-feed/daed/${RELEASE}/${ARCH}"

# DAED: keep the feed available in the finished firmware. The upstream
# installer is intentionally used at runtime because it detects the exact
# OpenWrt release/architecture and installs the matching signing key.
cat > "$BUILDER_REPO_DIR/customfeeds.list" <<EOF
${PASSWALL_BASE}/passwall_luci/packages.adb
${PASSWALL_BASE}/passwall_packages/packages.adb
${PASSWALL_BASE}/passwall2/packages.adb
${DAED_BASE}/packages.adb
EOF
cp -f "$BUILDER_REPO_DIR/customfeeds.list" "$TARGET_REPO_DIR/customfeeds.list"

# Keep the upstream DAED installer in the firmware for one-command installation.
mkdir -p "$FILES_DIR/usr/libexec"
cat > "$FILES_DIR/usr/libexec/install-daede-feed.sh" <<'EOF'
#!/bin/sh
set -eu
wget -qO- https://down.dllkids.xyz/openwrt-feed/openwrt-feed-setup.sh | sh
apk update
apk add dae daed luci-app-daede
EOF
chmod 0755 "$FILES_DIR/usr/libexec/install-daede-feed.sh"
