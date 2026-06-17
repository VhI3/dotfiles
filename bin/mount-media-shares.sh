#!/usr/bin/env bash
set -euo pipefail

SMB_HOST="${SMB_HOST:-192.168.178.114}"
FILME_SHARE="${FILME_SHARE:-Filme}"
TV_SHOWS_SHARE="${TV_SHOWS_SHARE:-TV Shows}"
FILME_MOUNT="${FILME_MOUNT:-/mnt/filme}"
TV_SHOWS_MOUNT="${TV_SHOWS_MOUNT:-/mnt/tv_show}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

"$SCRIPT_DIR/mount-smb-share" "//$SMB_HOST/$FILME_SHARE" "$FILME_MOUNT"
"$SCRIPT_DIR/mount-smb-share" "//$SMB_HOST/$TV_SHOWS_SHARE" "$TV_SHOWS_MOUNT"

echo "All media shares mounted."
