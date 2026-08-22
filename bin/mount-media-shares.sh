#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
media_env="${HOME}/.config/dotfiles/media-shares.env"

if [ -f "$media_env" ]; then
  # shellcheck disable=SC1090
  . "$media_env"
fi

SMB_HOST="${SMB_HOST:-media-server.local}"

FILME_SHARE="${FILME_SHARE:-Filme}"
TV_SHOWS_SHARE="${TV_SHOWS_SHARE:-Series}"
AUDIOBOOKS_SHARE="${AUDIOBOOKS_SHARE:-}"
MUSIC_SHARE="${MUSIC_SHARE:-}"
PAPERLESS_CONSUME_SHARE="${PAPERLESS_CONSUME_SHARE:-}"

FILME_MOUNT="${FILME_MOUNT:-/mnt/filme}"
TV_SHOWS_MOUNT="${TV_SHOWS_MOUNT:-/mnt/tv_show}"
AUDIOBOOKS_MOUNT="${AUDIOBOOKS_MOUNT:-/mnt/audiobooks}"
MUSIC_MOUNT="${MUSIC_MOUNT:-/mnt/music}"
PAPERLESS_CONSUME_MOUNT="${PAPERLESS_CONSUME_MOUNT:-/mnt/paperless-consume}"

mount_one() {
  local share_name="$1"
  local mount_point="$2"

  echo "==> Mounting //$SMB_HOST/$share_name -> $mount_point"
  if ! "$SCRIPT_DIR/mount-smb-share.sh" "//$SMB_HOST/$share_name" "$mount_point"; then
    echo "mount-media-shares: failed to mount //$SMB_HOST/$share_name at $mount_point" >&2
    return 1
  fi
}

mount_one "$FILME_SHARE" "$FILME_MOUNT"
mount_one "$TV_SHOWS_SHARE" "$TV_SHOWS_MOUNT"

if [ -n "$AUDIOBOOKS_SHARE" ]; then
  mount_one "$AUDIOBOOKS_SHARE" "$AUDIOBOOKS_MOUNT"
fi

if [ -n "$MUSIC_SHARE" ]; then
  mount_one "$MUSIC_SHARE" "$MUSIC_MOUNT"
fi

if [ -n "$PAPERLESS_CONSUME_SHARE" ]; then
  mount_one "$PAPERLESS_CONSUME_SHARE" "$PAPERLESS_CONSUME_MOUNT"
fi

echo "All media shares mounted."
