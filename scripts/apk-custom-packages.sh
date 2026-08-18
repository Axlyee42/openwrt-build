#!/usr/bin/env bash
#
# OpenWrt x86-64 ImageBuilder third-party APK packages
#
# Responsibilities:
#   1. Clone the prebuilt x86 APK repository.
#   2. Select the requested third-party packages.
#   3. Deduplicate multiple versions of the same package.
#   4. Copy the selected APKs into ImageBuilder/packages/.
#   5. Write the package names for the workflow.
#
# This script does NOT:
#   - compile packages
#   - modify OpenWrt .config
#   - run make image
#   - modify LAN configuration
#

set -Eeuo pipefail

IMAGEBUILDER_DIR="${IMAGEBUILDER_DIR:?IMAGEBUILDER_DIR is required}"
APK_REPO="${APK_REPO:-https://github.com/wukongdaily/apk.git}"
APK_TMP="${RUNNER_TEMP:-/tmp}/wukongdaily-apk"

PACKAGE_DIR="${IMAGEBUILDER_DIR}/packages"
PACKAGE_LIST="${IMAGEBUILDER_DIR}/.third-party-packages"

mkdir -p "${PACKAGE_DIR}"

rm -f "${PACKAGE_LIST}"
rm -rf "${APK_TMP}"

log() {
    printf '\033[1;32m[APK] %s\033[0m\n' "$*"
}

die() {
    printf '\033[1;31m[APK] ERROR: %s\033[0m\n' "$*" >&2
    exit 1
}

# Package names intentionally have no version suffix.
# Dependencies which are also third-party packages are included explicitly.
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

log "Cloning ${APK_REPO}"
git clone --depth=1 "${APK_REPO}" "${APK_TMP}"

SRC="${APK_TMP}/run/x86"
test -d "${SRC}" || die "APK repository does not contain run/x86"

# Temporary staging area. We deliberately do not copy every APK into the
# final repository because the source repository contains multiple versions
# of some packages.
STAGE="${APK_TMP}/selected"
mkdir -p "${STAGE}"

log "Selecting requested packages"

for pkg in ${REQUESTED_PACKAGES}; do
    candidates=()

    while IFS= read -r -d '' apk; do
        pkgname="$(
            tar -xOf "${apk}" .PKGINFO 2>/dev/null |
              awk -F' = ' '$1 == "pkgname" {print $2; exit}'
        )"

        [[ "${pkgname}" == "${pkg}" ]] &&
            candidates+=("${apk}")
    done < <(
        find "${SRC}" \
            -type f \
            -name '*.apk' \
            -print0
    )

    if (( ${#candidates[@]} == 0 )); then
        echo "ERROR: requested APK package is missing: ${pkg}" >&2
        echo
        echo "Available package names:"
        find "${SRC}" \
            -type f \
            -name '*.apk' \
            -print0 |
        while IFS= read -r -d '' apk; do
            tar -xOf "${apk}" .PKGINFO 2>/dev/null |
                awk -F' = ' '$1 == "pkgname" {print $2; exit}'
        done |
        sort -u
        exit 1
    fi

    # Extract package version from .PKGINFO and select the greatest version.
    best=""
    best_ver=""

    for apk in "${candidates[@]}"; do
        ver="$(
            tar -xOf "${apk}" .PKGINFO 2>/dev/null |
              awk -F' = ' '$1 == "pkgver" {print $2; exit}'
        )"

        if [[ -z "${best}" ]]; then
            best="${apk}"
            best_ver="${ver}"
            continue
        fi

        # OpenWrt/Alpine-style package versions are close enough to version
        # sorting for this repository. If sort cannot establish an order,
        # keep the first candidate.
        if [[ -n "${ver}" && -n "${best_ver}" ]]; then
            newer="$(
                printf '%s\n%s\n' "${best_ver}" "${ver}" |
                  sort -V |
                  tail -n 1
            )"

            if [[ "${newer}" == "${ver}" && "${ver}" != "${best_ver}" ]]; then
                best="${apk}"
                best_ver="${ver}"
            fi
        fi
    done

    cp -f "${best}" "${STAGE}/${pkg}.apk"

    log "${pkg} -> $(basename "${best}")"
done

# Clean the ImageBuilder local repository and install exactly one version
# of every requested third-party package.
find "${PACKAGE_DIR}" \
    -maxdepth 1 \
    -type f \
    -name '*.apk' \
    -delete

cp -f "${STAGE}"/*.apk "${PACKAGE_DIR}/"

# This file is consumed by the next workflow step. One package name per line.
printf '%s\n' ${REQUESTED_PACKAGES} |
    sort -u > "${PACKAGE_LIST}"

# Never let old/generated package indexes survive after replacing APKs.
rm -f \
    "${PACKAGE_DIR}/packages.adb" \
    "${PACKAGE_DIR}/Packages" \
    "${PACKAGE_DIR}/Packages.gz" \
    "${PACKAGE_DIR}/Packages.sig"

log "Third-party APK preparation completed."

echo
echo "Selected packages:"
cat "${PACKAGE_LIST}"

echo
echo "Selected APK files:"
find "${PACKAGE_DIR}" \
    -maxdepth 1 \
    -type f \
    -name '*.apk' \
    -printf '%f\n' |
    sort
