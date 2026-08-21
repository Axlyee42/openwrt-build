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

PASSWALL_KEY_URL='https://master.dl.sourceforge.net/project/openwrt-passwall-build/apk.pub'
PASSWALL_KEY="$BUILDER_KEY_DIR/openwrt-passwall-build.pem"
curl -fL "$PASSWALL_KEY_URL" -o "$PASSWALL_KEY"
cp -f "$PASSWALL_KEY" "$TARGET_KEY_DIR/openwrt-passwall-build.pem"

PASSWALL_BASE="https://master.dl.sourceforge.net/project/openwrt-passwall-build/releases/packages-${RELEASE}/${ARCH}"
DAED_BASE="https://down.dllkids.xyz/openwrt-feed/daed/${RELEASE}/${ARCH}"

# kenzok8/openwrt-daede publishes a signed APK feed and its setup script is the
# authoritative resolver for the feed key. We extract the public-key URL from
# that setup script instead of hard-coding a key URL that may change.
DAEDE_SETUP_URL='https://down.dllkids.xyz/openwrt-feed/openwrt-feed-setup.sh'
DAEDE_SETUP="$(curl -fsSL "$DAEDE_SETUP_URL")"
DAEDE_KEY_URL="$(printf '%s\n' "$DAEDE_SETUP" | grep -oE 'https?[^\"'"'"'[:space:]]+\.(pub|pem)' | head -n 1 || true)"
if [ -z "$DAEDE_KEY_URL" ]; then
  echo 'ERROR: unable to discover the DAED APK signing key URL from the upstream setup script.' >&2
  exit 1
fi

DAEDE_KEY="$BUILDER_KEY_DIR/openwrt-daede.pem"
curl -fL "$DAEDE_KEY_URL" -o "$DAEDE_KEY"
cp -f "$DAEDE_KEY" "$TARGET_KEY_DIR/openwrt-daede.pem"

cat > "$BUILDER_REPO_DIR/customfeeds.list" <<EOF
${PASSWALL_BASE}/passwall_luci/packages.adb
${PASSWALL_BASE}/passwall_packages/packages.adb
${PASSWALL_BASE}/passwall2/packages.adb
${DAED_BASE}/packages.adb
EOF
cp -f "$BUILDER_REPO_DIR/customfeeds.list" "$TARGET_REPO_DIR/customfeeds.list"

# Runtime helper: the upstream installer performs architecture/SDK detection,
# adds the matching feed/key and installs dae/daed/luci-app-daede.
mkdir -p "$FILES_DIR/usr/libexec"
cat > "$FILES_DIR/usr/libexec/install-daede-feed.sh" <<'EOF'
#!/bin/sh
set -eu
wget -qO- https://down.dllkids.xyz/openwrt-feed/openwrt-feed-setup.sh | sh
apk update
apk add dae daed luci-app-daede
EOF
chmod 0755 "$FILES_DIR/usr/libexec/install-daede-feed.sh"
