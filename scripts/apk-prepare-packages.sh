#!/bin/sh
#
# OpenWrt 25.12.x APK ImageBuilder package preparation.
#
# Input:
#   extra-packages/
#     *.run
#     *.apk
#     */*.apk
#
# Output:
#   packages/*.apk
#
# This intentionally mirrors the upstream wukongdaily ImageBuilder
# preparation model. The .run files are makeself archives containing
# the actual APK files.
#

set -eu

BASE_DIR="${BASE_DIR:-extra-packages}"
TEMP_DIR="${BASE_DIR}/temp-unpack"
TARGET_DIR="${TARGET_DIR:-packages}"

rm -rf "${TEMP_DIR}" "${TARGET_DIR}"
mkdir -p "${TEMP_DIR}" "${TARGET_DIR}"

echo "[APK] extra-packages: ${BASE_DIR}"

# Extract all x86 .run packages.
find "${BASE_DIR}" \
  -maxdepth 1 \
  -type f \
  -name '*.run' \
  -print |
while IFS= read -r run_file; do
    echo "[APK] extracting: ${run_file}"

    chmod +x "${run_file}"

    sh "${run_file}" \
      --target "${TEMP_DIR}" \
      --noexec
done

# Collect APKs extracted from .run files.
find "${TEMP_DIR}" \
  -type f \
  -name '*.apk' \
  -exec cp -f {} "${TARGET_DIR}/" \;

# Also collect direct APKs in extra-packages and its first-level
# package directories.
find "${BASE_DIR}" \
  -mindepth 1 \
  -maxdepth 2 \
  -type f \
  -name '*.apk' \
  ! -path "${TEMP_DIR}/*" \
  -exec cp -f {} "${TARGET_DIR}/" \;

echo
echo "[APK] prepared files:"
find "${TARGET_DIR}" \
  -maxdepth 1 \
  -type f \
  -name '*.apk' \
  -printf '%f\n' |
sort

if ! find "${TARGET_DIR}" \
    -maxdepth 1 \
    -type f \
    -name '*.apk' \
    -print \
    -quit |
    grep -q .; then
    echo "[APK] ERROR: no APK files were prepared." >&2
    exit 1
fi

echo
echo "[APK] preparation completed."
