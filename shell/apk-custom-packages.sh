set -euo pipefail

echo
echo "=========================================="
echo "Verifying ImageBuilder package selection"
echo "=========================================="

if [ ! -f selected-packages.txt ]; then
  echo "ERROR: selected-packages.txt not found."
  exit 1
fi

FAILED=0

REQUIRED_PACKAGES="
luci
luci-i18n-base-zh-cn
luci-app-package-manager
luci-i18n-package-manager-zh-cn

luci-app-mwan3
luci-app-upnp
luci-app-ttyd

luci-app-passwall
luci-i18n-passwall-zh-cn

geoview
xray-core
sing-box
hysteria

luci-app-openclash

kmod-nft-socket
kmod-nft-tproxy

luci-theme-aurora
luci-app-aurora-config
luci-i18n-aurora-config-zh-cn

luci-theme-shadcn

bandix
luci-app-bandix
luci-i18n-bandix-zh-cn

luci-app-run

luci-app-filebrowser-go
luci-app-vlmcsd
luci-app-timewol
luci-app-autoreboot
"

while IFS= read -r PACKAGE; do

  [ -z "${PACKAGE}" ] && continue

  if grep -Fxq "${PACKAGE}" selected-packages.txt; then
    echo "OK selected: ${PACKAGE}"
  else
    echo "WARNING not selected: ${PACKAGE}"
    FAILED=1
  fi

done <<< "${REQUIRED_PACKAGES}"


echo
echo "=========================================="
echo "Checking local third-party APKs"
echo "=========================================="

THIRD_PARTY_PACKAGES="
luci-theme-aurora
luci-app-aurora-config
luci-i18n-aurora-config-zh-cn
luci-theme-shadcn
bandix
luci-app-bandix
luci-i18n-bandix-zh-cn
luci-app-run
luci-app-filebrowser-go
luci-app-vlmcsd
luci-app-timewol
luci-app-autoreboot
luci-app-openclash
"

while IFS= read -r PACKAGE; do

  [ -z "${PACKAGE}" ] && continue

  if find imagebuilder/packages \
    -maxdepth 1 \
    -type f \
    -name "${PACKAGE}-*.apk" \
    -print \
    -quit |
    grep -q .
  then
    echo "OK local APK: ${PACKAGE}"
  else

    #
    # 这些包允许由配置好的第三方 APK feed
    # 在 ImageBuilder 阶段提供。
    #

    case "${PACKAGE}" in

      luci-theme-aurora)
        echo "OK feed candidate: ${PACKAGE}"
        ;;

      luci-app-aurora-config)
        echo "OK feed candidate: ${PACKAGE}"
        ;;

      luci-i18n-aurora-config-zh-cn)
        echo "OK feed candidate: ${PACKAGE}"
        ;;

      luci-theme-shadcn)
        echo "OK feed candidate: ${PACKAGE}"
        ;;

      luci-app-passwall)
        echo "OK feed candidate: ${PACKAGE}"
        ;;

      luci-i18n-passwall-zh-cn)
        echo "OK feed candidate: ${PACKAGE}"
        ;;

      luci-app-openclash)
        echo "OK feed candidate: ${PACKAGE}"
        ;;

      *)
        echo "INFO: APK not local, expected from configured feed: ${PACKAGE}"
        ;;

    esac

  fi

done <<< "${THIRD_PARTY_PACKAGES}"


echo
echo "=========================================="
echo "Verification result"
echo "=========================================="

if [ "${FAILED}" -ne 0 ]; then

  echo
  echo "ERROR: Required packages are missing from selected-packages.txt."
  echo
  echo "Current selected packages:"
  cat selected-packages.txt
  echo

  exit 1

fi

echo "All required packages are selected."
