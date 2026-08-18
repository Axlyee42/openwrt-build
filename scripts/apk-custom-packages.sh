#!/usr/bin/env bash
#
# OpenWrt x86-64 ImageBuilder third-party APK integration
#
# Based on the integration model used by:
#   wukongdaily/ImmortalWrt-ImageBuilder
#
# This script DOES NOT compile third-party packages.
# It downloads the prebuilt APK repository and makes the selected APKs
# available to the ImageBuilder.
#

set -Eeuo pipefail

IMAGEBUILDER_DIR="${IMAGEBUILDER_DIR:?IMAGEBUILDER_DIR is required}"

APK_REPO="${APK_REPO:-https://github.com/wukongdaily/apk.git}"
APK_TMP="${RUNNER_TEMP:-/tmp}/wukongdaily-apk"

rm -rf "$APK_TMP"
git clone --depth=1 "$APK_REPO" "$APK_TMP"

SRC="$APK_TMP/run/x86"
test -d "$SRC"

# The ImageBuilder expects locally available packages under packages/.
mkdir -p "${IMAGEBUILDER_DIR}/packages"

# Copy all prebuilt APKs for x86. We do NOT compile anything here.
find "$SRC" -type f -name '*.apk' -print0 |
  while IFS= read -r -d '' apk; do
    cp -f "$apk" "${IMAGEBUILDER_DIR}/packages/"
  done

# Fixed third-party package selection.
# Version numbers are intentionally omitted.
CUSTOM_PACKAGES="
bandix
chinadns-ng
clashoo
dae
daed
dns2socks
dns2tcp
geoview
hysteria
ipt2socks
lua-neturl
luci-app-argon-config
luci-app-aurora-config
luci-app-bandix
luci-app-clashoo
luci-app-daed
luci-app-daede
luci-app-lucky
luci-app-mosdns
luci-app-nikki
luci-app-partexp
luci-app-passwall
luci-app-passwall2
luci-app-quickfile
luci-app-quickstart
luci-app-rtp2httpd
luci-app-run
luci-app-ssr-plus
luci-app-store
luci-app-taskplan
luci-i18n-argon-config-zh-cn
luci-i18n-aurora-config-zh-cn
luci-i18n-bandix-zh-cn
luci-i18n-clashoo-zh-cn
luci-i18n-daed-zh-cn
luci-i18n-lucky-zh-cn
luci-i18n-mosdns-zh-cn
luci-i18n-nikki-zh-cn
luci-i18n-partexp-zh-cn
luci-i18n-passwall-zh-cn
luci-i18n-passwall2-zh-cn
luci-i18n-quickfile-zh-cn
luci-i18n-quickstart-zh-cn
luci-i18n-rtp2httpd-zh-cn
luci-i18n-ssr-plus-zh-cn
luci-i18n-taskplan-zh-cn
luci-lib-taskd
luci-lib-xterm
luci-theme-argon
luci-theme-aurora
lucky
mosdns
naiveproxy
nikki
quickfile
quickstart
rtp2httpd
shadowsocksr-libev-ssr-check
shadowsocksr-libev-ssr-local
shadowsocksr-libev-ssr-nat
shadowsocksr-libev-ssr-redir
shadowsocksr-libev-ssr-server
sing-box
taskd
tcping
v2dat
v2ray-geoip
v2ray-geosite
xray-core
"

# Normalize whitespace for PACKAGES="..."
CUSTOM_PACKAGES="$(printf '%s\n' "$CUSTOM_PACKAGES" | xargs)"

# Validate every requested package against the downloaded APK filenames.
missing=()

for pkg in $CUSTOM_PACKAGES; do
  if ! find "${IMAGEBUILDER_DIR}/packages" \
      -maxdepth 1 \
      -type f \
      -name "${pkg}-*.apk" \
      -print -quit |
      grep -q .; then
    missing+=("$pkg")
  fi
done

if (( ${#missing[@]} )); then
  echo "ERROR: One or more requested third-party APK packages are missing."
  echo
  printf 'Missing:\n'
  printf '  %s\n' "${missing[@]}"
  echo
  echo "Available APK packages:"
  find "${IMAGEBUILDER_DIR}/packages" \
    -maxdepth 1 \
    -type f \
    -name '*.apk' \
    -printf '  %f\n' |
    sort
  exit 1
fi

export CUSTOM_PACKAGES

echo "Third-party APK packages:"
printf '  %s\n' $CUSTOM_PACKAGES
