#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
IMAGEBUILDER_DIR="${IMAGEBUILDER_DIR:-$(pwd)}"
FILES_DIR="$IMAGEBUILDER_DIR/files"
PACKAGES_DIR="$IMAGEBUILDER_DIR/packages"
EXTRA_DIR="$IMAGEBUILDER_DIR/extra-packages"

source "$REPO_ROOT/shell/apk-custom-packages.sh"
echo "第三方 apk 软件包: ${CUSTOM_PACKAGES:-无}"
echo "编译固件大小为: ${PROFILE:-1024} MB"
echo "Include Docker: ${INCLUDE_DOCKER:-no}"

mkdir -p "$FILES_DIR/etc/config"
cat > "$FILES_DIR/etc/config/pppoe-settings" <<EOF
enable_pppoe=${ENABLE_PPPOE:-no}
pppoe_account=${PPPOE_ACCOUNT:-}
pppoe_password=${PPPOE_PASSWORD:-}
EOF

if [ -n "${CUSTOM_PACKAGES:-}" ]; then
  echo "🔄 正在同步第三方软件仓库 Cloning run file repo..."
  rm -rf /tmp/store-apk-repo
  git clone --depth=1 https://github.com/wukongdaily/apk.git /tmp/store-apk-repo
  rm -rf "$EXTRA_DIR"
  mkdir -p "$EXTRA_DIR"
  cp -r /tmp/store-apk-repo/run/x86/* "$EXTRA_DIR/"
  "$REPO_ROOT/shell/apk-prepare-packages.sh"
  echo "✅ Run files copied to extra-packages"
  ls -lah "$PACKAGES_DIR" || true
fi

# Only packages available from the official OpenWrt 25.12.5 x86/64 repositories
# Third-party packages are selected exclusively through shell/apk-custom-packages.sh.
PACKAGES=""
PACKAGES="$PACKAGES curl"
PACKAGES="$PACKAGES luci-i18n-firewall-zh-cn"
PACKAGES="$PACKAGES luci-i18n-package-manager-zh-cn"
PACKAGES="$PACKAGES luci-i18n-ttyd-zh-cn"
PACKAGES="$PACKAGES openssh-sftp-server"
PACKAGES="$PACKAGES luci-i18n-filemanager-zh-cn"
PACKAGES="$PACKAGES ${CUSTOM_PACKAGES:-}"

if [ "${INCLUDE_DOCKER:-no}" = "yes" ]; then
    PACKAGES="$PACKAGES luci-i18n-dockerman-zh-cn"
fi

if echo "$PACKAGES" | grep -q "luci-app-openclash"; then
    mkdir -p "$FILES_DIR/etc/openclash/core"
    META_URL="https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-amd64-v1.tar.gz"
    wget -qO- "$META_URL" | tar xOvz > "$FILES_DIR/etc/openclash/core/clash_meta"
    chmod +x "$FILES_DIR/etc/openclash/core/clash_meta"
    wget -q https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat -O "$FILES_DIR/etc/openclash/GeoIP.dat"
    wget -q https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat -O "$FILES_DIR/etc/openclash/GeoSite.dat"
    URL=$(curl -s https://api.github.com/repos/vernesong/OpenClash/releases/latest | grep "browser_download_url.*apk" | head -n1 | cut -d '"' -f 4)
    wget "$URL" -P "$PACKAGES_DIR"
fi

if echo "$PACKAGES" | grep -q "luci-app-ssr-plus"; then
    mkdir -p "$FILES_DIR/usr/bin"
    MIHOMO_URL="https://github.com/MetaCubeX/mihomo/releases/download/v1.19.24/mihomo-linux-amd64-compatible-v1.19.24.gz"
    wget -qO- "$MIHOMO_URL" | gzip -dc > "$FILES_DIR/usr/bin/mihomo"
    chmod +x "$FILES_DIR/usr/bin/mihomo"
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') - 开始构建 OpenWrt 固件..."
make image PROFILE="generic" PACKAGES="$PACKAGES" FILES="$FILES_DIR" ROOTFS_PARTSIZE="${PROFILE:-1024}"
echo "$(date '+%Y-%m-%d %H:%M:%S') - Build completed successfully."