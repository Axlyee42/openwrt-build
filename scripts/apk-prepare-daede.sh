#!/bin/sh

set -eux

TARGET_DIR="${1:-files}"

mkdir -p "${TARGET_DIR}/etc/apk/keys"
mkdir -p "${TARGET_DIR}/etc/apk/repositories.d"

# daede APK feed
# The repository provides dae/daed related packages.

if [ -n "${DAEDE_APK_KEY_URL:-}" ]; then
    wget -O "${TARGET_DIR}/etc/apk/keys/daede.pem" "${DAEDE_APK_KEY_URL}"
fi

cat > "${TARGET_DIR}/etc/apk/repositories.d/daede.list" <<EOF
# daede third party APK feed
# Fill with the official daede APK repository URL when enabled.
EOF

chmod 644 "${TARGET_DIR}/etc/apk/repositories.d/daede.list"
