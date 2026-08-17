#!/usr/bin/env bash

set -euo pipefail


OPENWRT_REPO="https://github.com/openwrt/openwrt.git"

STATE_FILE="openwrt-version"


echo
echo "=========================================="
echo "OpenWrt 25.12 upstream check"
echo "=========================================="


# ==============================================================
# 获取最新 25.12.x
# ==============================================================

LATEST="$(
    git ls-remote \
        --tags \
        "${OPENWRT_REPO}" \
        'refs/tags/v25.12.*' |
    sed 's#.*refs/tags/v##' |
    grep -E '^25\.12\.[0-9]+$' |
    sort -V |
    tail -1
)


if [ -z "${LATEST}" ]; then

    echo "ERROR: Cannot find OpenWrt 25.12.x release."

    exit 1

fi


echo
echo "Latest OpenWrt:"
echo "${LATEST}"


# ==============================================================
# 当前版本
# ==============================================================

CURRENT=""

if [ -f "${STATE_FILE}" ]; then
    CURRENT="$(cat "${STATE_FILE}")"
fi


echo
echo "Current OpenWrt:"
echo "${CURRENT:-none}"


# ==============================================================
# 比较
# ==============================================================

if [ "${LATEST}" = "${CURRENT}" ]; then

    echo
    echo "=========================================="
    echo "No update."
    echo "=========================================="

    exit 0

fi


# ==============================================================
# 更新版本文件
# ==============================================================

echo "${LATEST}" > "${STATE_FILE}"


echo
echo "=========================================="
echo "OpenWrt update detected"
echo "=========================================="

echo
echo "Old:"
echo "${CURRENT:-none}"

echo
echo "New:"
echo "${LATEST}"

echo
echo "Version file updated:"
echo "${STATE_FILE}"


exit 0
