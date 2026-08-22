#!/bin/bash
set -e

IMAGE_FILES_DIR="${FILES_DIR:-${IMAGEBUILDER_DIR:-$(pwd)}/files}"
APK_DIR="$IMAGE_FILES_DIR/etc/apk/repositories.d"
KEY_DIR="$IMAGE_FILES_DIR/etc/apk/keys"
UCI_DIR="$IMAGE_FILES_DIR/etc/uci-defaults"

mkdir -p "$APK_DIR" "$KEY_DIR" "$UCI_DIR"

# Third-party APK feeds removed.
# PassWall, Aurora and daede repositories are intentionally not added here.
# Users can add their preferred third-party repositories manually after installation.

# Keep first boot package refresh only for official OpenWrt repositories.
cat > "$UCI_DIR/98-thirdparty-apk-update" <<'EOF'
#!/bin/sh
apk update || true
exit 0
EOF

chmod +x "$UCI_DIR/98-thirdparty-apk-update"
