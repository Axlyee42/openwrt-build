#!/usr/bin/env bash
#
# OpenWrt 25.12.x x86-64 third-party APK integration.
#
# Modelled after wukongdaily/ImmortalWrt-ImageBuilder:
#   1. clone the prebuilt APK/run repository
#   2. unpack .run bundles
#   3. collect x86 APKs
#   4. keep only the newest version of each requested package
#   5. place them in ImageBuilder/packages
#
# The official OpenWrt 25.12 ImageBuilder automatically runs:
#   apk mkndx ... packages.adb
# when make image is executed. We therefore do NOT hand-create
# packages.adb here.
#

set -Eeuo pipefail

IMAGEBUILDER_DIR="${IMAGEBUILDER_DIR:?IMAGEBUILDER_DIR is required}"

APK_REPO="${APK_REPO:-https://github.com/wukongdaily/apk.git}"
APK_BRANCH="${APK_BRANCH:-master}"

WORK="${RUNNER_TEMP:-/tmp}/openwrt-third-party-apk"
EXTRA="${WORK}/extra-packages"
UNPACK="${EXTRA}/temp-unpack"
PACKAGES_DIR="${IMAGEBUILDER_DIR}/packages"

rm -rf "${WORK}"
mkdir -p "${EXTRA}" "${PACKAGES_DIR}"

echo "============================================================"
echo "Downloading third-party APK repository"
echo "Repository: ${APK_REPO}"
echo "Branch    : ${APK_BRANCH}"
echo "============================================================"

git clone \
  --depth=1 \
  --single-branch \
  --branch="${APK_BRANCH}" \
  "${APK_REPO}" \
  "${WORK}/repo"

SRC="${WORK}/repo/run/x86"
test -d "${SRC}" || {
  echo "ERROR: ${SRC} does not exist."
  exit 1
}

cp -a "${SRC}/." "${EXTRA}/"

rm -rf "${UNPACK}"
mkdir -p "${UNPACK}"

echo
echo "Unpacking .run bundles..."

shopt -s nullglob
for run_file in "${EXTRA}"/*.run; do
  echo "  -> $(basename "${run_file}")"
  sh "${run_file}" --target "${UNPACK}" --noexec
done

# Collect every x86 APK supplied directly or by a .run bundle.
mapfile -d '' ALL_APKS < <(
  find "${EXTRA}" "${UNPACK}" \
    -type f \
    -name '*.apk' \
    ! -path "${PACKAGES_DIR}/*" \
    -print0
)

if (( ${#ALL_APKS[@]} == 0 )); then
  echo "ERROR: No x86 APK files were found."
  exit 1
fi

# ---------------------------------------------------------------------------
# Requested third-party package list.
#
# This is the package list from the user's previously verified x86 APK set.
# vmlinux-btf is deliberately excluded: it is a kernel/build artifact,
# not a normal third-party package to install through PACKAGES.
# ---------------------------------------------------------------------------

read -r -d '' REQUESTED_PACKAGES <<'EOF' || true
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
EOF

# ---------------------------------------------------------------------------
# Extract package metadata from APK .PKGINFO.
# ---------------------------------------------------------------------------

declare -A BEST_FILE=()
declare -A BEST_VER=()

get_pkginfo() {
  local file="$1"
  tar -xOf "${file}" .PKGINFO 2>/dev/null || \
  tar -xOf "${file}" .PKGINFO.gz 2>/dev/null || true
}

echo
echo "Indexing discovered APKs..."

for apk in "${ALL_APKS[@]}"; do
  info="$(get_pkginfo "${apk}")"
  pkg="$(printf '%s\n' "${info}" | awk -F= '$1=="pkgname"{print $2; exit}')"
  ver="$(printf '%s\n' "${info}" | awk -F= '$1=="pkgver"{print $2; exit}')"

  # Fallback to filename when .PKGINFO is unavailable.
  if [[ -z "${pkg}" ]]; then
    base="$(basename "${apk}" .apk)"
    pkg="${base%%-[0-9]*}"
  fi

  if [[ -z "${ver}" ]]; then
    ver="$(basename "${apk}" .apk | sed "s/^${pkg}-//")"
  fi

  [[ -n "${pkg}" ]] || continue

  if [[ -z "${BEST_FILE[$pkg]:-}" ]]; then
    BEST_FILE["${pkg}"]="${apk}"
    BEST_VER["${pkg}"]="${ver}"
    continue
  fi

  old="${BEST_VER[$pkg]}"

  # apk's version comparator is preferable when available.
  if command -v apk >/dev/null 2>&1; then
    if apk version --test "${ver}" "${old}" 2>/dev/null | grep -q '^>'; then
      BEST_FILE["${pkg}"]="${apk}"
      BEST_VER["${pkg}"]="${ver}"
    fi
  else
    if [[ "$(printf '%s\n' "${old}" "${ver}" | sort -V | tail -n1)" == "${ver}" \
          && "${ver}" != "${old}" ]]; then
      BEST_FILE["${pkg}"]="${apk}"
      BEST_VER["${pkg}"]="${ver}"
    fi
  fi
done

# Copy exactly one newest APK for every requested package.
rm -f "${PACKAGES_DIR}"/*.apk

MISSING=()
CUSTOM_PACKAGES=""

for pkg in ${REQUESTED_PACKAGES}; do
  file="${BEST_FILE[$pkg]:-}"

  if [[ -z "${file}" ]]; then
    MISSING+=("${pkg}")
    continue
  fi

  cp -f "${file}" "${PACKAGES_DIR}/"
  CUSTOM_PACKAGES+=" ${pkg}"
done

if (( ${#MISSING[@]} )); then
  echo
  echo "ERROR: requested third-party APK packages are missing."
  echo
  printf 'Missing packages:\n'
  printf '  %s\n' "${MISSING[@]}"
  echo
  echo "This normally means the package is not currently supplied by"
  echo "wukongdaily/apk under run/x86. No fake package entry is created."
  echo
  echo "Available discovered package names:"
  printf '%s\n' "${!BEST_FILE[@]}" | sort
  exit 1
fi

CUSTOM_PACKAGES="$(printf '%s' "${CUSTOM_PACKAGES}" | xargs)"

echo
echo "============================================================"
echo "Selected third-party APKs"
echo "============================================================"

for pkg in ${CUSTOM_PACKAGES}; do
  printf '  %-42s %s\n' \
    "${pkg}" \
    "${BEST_VER[$pkg]}"
done

echo
echo "Third-party APK count: $(printf '%s\n' ${CUSTOM_PACKAGES} | wc -l)"

# Export for the next GitHub Actions step.
if [[ -n "${GITHUB_ENV:-}" ]]; then
  {
    printf 'CUSTOM_PACKAGES=%s\n' "${CUSTOM_PACKAGES}"
  } >> "${GITHUB_ENV}"
fi

# Also export for callers that source this script.
export CUSTOM_PACKAGES
