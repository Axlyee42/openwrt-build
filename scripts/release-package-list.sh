#!/bin/sh
set -eu

# Release notes should show user-selected optional software, but not the
# default LuCI/base localization packages or per-app Chinese translation
# packages. Those packages are still installed when selected; they are only
# omitted from the human-readable Release list.

awk '
  NF == 0 { next }
  $0 == "luci" { next }
  $0 == "luci-app-package-manager" { next }
  $0 == "luci-i18n-base-zh-cn" { next }
  $0 == "luci-i18n-firewall-zh-cn" { next }
  $0 == "luci-i18n-package-manager-zh-cn" { next }
  $0 ~ /^luci-i18n-/ { next }
  !seen[$0]++ { print $0 }
' "$1"
