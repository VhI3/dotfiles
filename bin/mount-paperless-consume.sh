#!/usr/bin/env bash
set -euo pipefail

SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
DOTFILES_DIR="$(cd "$(dirname "$SCRIPT_PATH")/.." && pwd)"
TOOLS_DIR="$DOTFILES_DIR/projects/paperless-tools"

# shellcheck disable=SC1091
. "$TOOLS_DIR/paperless-tools.lib.sh"
paperless_load_config

share="${PAPERLESS_CONSUME_SMB_SHARE:-}"
mount_point="${PAPERLESS_CONSUME_MOUNT:-$PAPERLESS_CONSUME_DIR}"

if [ -z "$share" ]; then
    cat >&2 <<EOF
mount-paperless-consume: PAPERLESS_CONSUME_SMB_SHARE is not configured.

Add this to ~/.config/dotfiles/paperless-tools.local.conf:
  PAPERLESS_CONSUME_SMB_SHARE="//192.168.1.10/Paperless-Consume"
  PAPERLESS_CONSUME_DIR="/mnt/paperless-consume"
  PAPERLESS_CONSUME_MOUNT="/mnt/paperless-consume"
EOF
    exit 1
fi

if [ -z "$mount_point" ]; then
    echo "mount-paperless-consume: PAPERLESS_CONSUME_MOUNT/PAPERLESS_CONSUME_DIR is empty." >&2
    exit 1
fi

if mountpoint -q "$mount_point"; then
    echo "$mount_point is already mounted."
    exit 0
fi

if [ -n "${PAPERLESS_SMB_CREDENTIALS_FILE:-}" ]; then
    export SMB_CREDENTIALS_FILE="$PAPERLESS_SMB_CREDENTIALS_FILE"
fi

"$DOTFILES_DIR/bin/mount-smb-share.sh" "$share" "$mount_point"
echo "Paperless consume share mounted at $mount_point"
