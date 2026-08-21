#!/bin/sh
set -eu

: "${OPENWRT_VERSION:?OPENWRT_VERSION is required}"
: "${ROOTFS_SIZE:?ROOTFS_SIZE is required}"
: "${LAN_IP:?LAN_IP is required}"

mkdir -p release-info
{
  echo "OpenWrt Version: ${OPENWRT_VERSION}"
  echo "Target: x86-64"
  echo "Firmware: UEFI + EXT4 + QCOW2"
  echo "Rootfs Size: ${ROOTFS_SIZE} MB"
  echo "LAN IP: ${LAN_IP}"
  echo "Build Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
  echo
  echo "Included APK/packages:"
  if [ -f /tmp/custom-packages.txt ]; then
    cat /tmp/custom-packages.txt
  else
    echo "None"
  fi
} > release-info/build-info.txt

cat release-info/build-info.txt
