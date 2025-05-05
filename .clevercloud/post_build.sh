#!/usr/bin/env bash
set -euo pipefail
  
LOCAL_BIN_DIR="$HOME/.local/bin"
RCLONE_CONFIG_DIR="$HOME/.config/rclone"

install_rclone() {
  curl -fsS -O https://downloads.rclone.org/rclone-current-linux-amd64.zip
  unzip rclone-current-linux-amd64.zip
  mkdir -p "$LOCAL_BIN_DIR"
  cp rclone-*-linux-amd64/rclone "$LOCAL_BIN_DIR"
  chmod 755 "$LOCAL_BIN_DIR/rclone"
} 

configure_rclone() {
  mkdir -p "$RCLONE_CONFIG_DIR"
  cat <<EOF > "$RCLONE_CONFIG_DIR/rclone.conf"
[SOURCE]
type = s3
provider = Other

[TARGET]
type = s3
provider = Other
EOF
}

install_rclone
configure_rclone
