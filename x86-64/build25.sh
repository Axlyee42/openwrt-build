#!/bin/bash
set -euo pipefail

# OpenWrt official ImageBuilder helper.
# The workflow downloads the official x86/64 ImageBuilder and invokes make image.
# Package selection remains in shell/apk-custom-packages.sh.

PROFILE="${PROFILE:-1024}"
PACKAGES="${PACKAGES:-}"
FILES="${FILES:-files}"

make image \
  PROFILE="generic" \
  PACKAGES="$PACKAGES" \
  FILES="$FILES" \
  ROOTFS_PARTSIZE="$PROFILE"
