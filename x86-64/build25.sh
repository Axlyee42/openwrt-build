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

echo "编译固件大小: ${PROFILE:-1024} MB"

mkdir -p "$FILES_DIR/etc/config"
cat > "$FILES_DIR/etc/config/pppoe-settings" <<EOF
enable_pppoe=${ENABLE_PPPOE:-no}
pppoe_account=${PPPOE_ACCOUNT:-}
pppoe_password=${PPPOE_PASSWORD:-}
EOF

# 写入第三方 APK 软件源配置
bash "$REPO_ROOT/shell/apk-prepare-thirdparty-sources.sh"

if [ -n "${CUSTOM_PACKAGES:-}" ]; then
  echo "同步第三方 apk 仓库"
  rm -rf /tmp/store-apk-repo
  git clone --depth=1 https://github.com/wukongdaily/apk.git /tmp/store-apk-repo
  rm -rf "$EXTRA_DIR"
  mkdir -p "$EXTRA_DIR"
  cp -r /tmp/store-apk-repo/run/x86/* "$EXTRA_DIR/"
  bash "$REPO_ROOT/shell/apk-prepare-packages.sh"
fi

# OpenWrt 25.12.5 基础组件，默认安装，不放入 apk-custom-packages.sh
PACKAGES=""
PACKAGES="$PACKAGES curl"
PACKAGES="$PACKAGES luci"
PACKAGES="$PACKAGES luci-base"
PACKAGES="$PACKAGES uhttpd"
PACKAGES="$PACKAGES uhttpd-mod-ubus"
PACKAGES="$PACKAGES luci-theme-bootstrap"
PACKAGES="$PACKAGES luci-compat"
PACKAGES="$PACKAGES luci-i18n-base-zh-cn"
PACKAGES="$PACKAGES luci-i18n-firewall-zh-cn"
PACKAGES="$PACKAGES luci-app-package-manager"
PACKAGES="$PACKAGES luci-i18n-package-manager-zh-cn"
PACKAGES="$PACKAGES kmod-nft-socket"
PACKAGES="$PACKAGES kmod-nft-tproxy"
PACKAGES="$PACKAGES openssh-sftp-server"

# 第三方 APK 由 apk-custom-packages.sh 管理
PACKAGES="$PACKAGES ${CUSTOM_PACKAGES:-}"

if [ "${INCLUDE_DOCKER:-no}" = "yes" ]; then
    PACKAGES="$PACKAGES luci-i18n-dockerman-zh-cn"
fi

if echo "$PACKAGES" | grep -q "luci-app-openclash"; then
    mkdir -p "$FILES_DIR/etc/openclash/core"
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') - 开始构建 OpenWrt 固件..."
make image PROFILE="generic" PACKAGES="$PACKAGES" FILES="$FILES_DIR" ROOTFS_PARTSIZE="${PROFILE:-1024}"

echo "$(date '+%Y-%m-%d %H:%M:%S') - Build completed successfully."