#!/usr/bin/env bash
#
# Optional helper mirroring wukongdaily's apk-prepare-packages.sh.
# The main workflow uses apk-custom-packages.sh directly.
#

set -Eeuo pipefail

BASE_DIR="${1:-extra-packages}"
TARGET_DIR="${2:-packages}"
TEMP_DIR="${BASE_DIR}/temp-unpack"

rm -rf "${TEMP_DIR}" "${TARGET_DIR}"
mkdir -p "${TEMP_DIR}" "${TARGET_DIR}"

shopt -s nullglob

for run_file in "${BASE_DIR}"/*.run; do
  echo "Unpacking: ${run_file}"
  sh "${run_file}" --target "${TEMP_DIR}" --noexec
done

find "${TEMP_DIR}" \
  -type f \
  -name '*.apk' \
  -exec cp -f {} "${TARGET_DIR}/" \;

find "${BASE_DIR}" \
  -mindepth 2 \
  -maxdepth 2 \
  -type f \
  -name '*.apk' \
  ! -path "${TEMP_DIR}/*" \
  -exec cp -f {} "${TARGET_DIR}/" \;

echo "APK files prepared under ${TARGET_DIR}/"
