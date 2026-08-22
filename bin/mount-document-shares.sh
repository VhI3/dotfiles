#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
media_env="${HOME}/.config/dotfiles/media-shares.env"
document_env="${HOME}/.config/dotfiles/document-shares.env"

if [ -f "$media_env" ]; then
  # Reuse SMB_HOST / SMB_CREDENTIALS_FILE when they are already configured.
  # shellcheck disable=SC1090
  . "$media_env"
fi

if [ -f "$document_env" ]; then
  # shellcheck disable=SC1090
  . "$document_env"
fi

SMB_HOST="${SMB_HOST:-media-server.local}"
DOCUMENTS_1_SHARE="${DOCUMENTS_1_SHARE:-Documents_1}"
DOCUMENTS_2_SHARE="${DOCUMENTS_2_SHARE:-Documents_2}"
DOCUMENTS_1_MOUNT="${DOCUMENTS_1_MOUNT:-/mnt/documents_1}"
DOCUMENTS_2_MOUNT="${DOCUMENTS_2_MOUNT:-/mnt/documents_2}"
DOCUMENTS_1_MOUNT_OPTIONS="${DOCUMENTS_1_MOUNT_OPTIONS:-}"
DOCUMENTS_2_CLIENT_READONLY="${DOCUMENTS_2_CLIENT_READONLY:-1}"
DOCUMENTS_2_MOUNT_OPTIONS="${DOCUMENTS_2_MOUNT_OPTIONS:-}"

mount_master=1
mount_mirror=1

usage() {
  cat <<'EOF'
Usage:
  mount-document-shares [options]

Mount home-server document disks on the Debian laptop.

Options:
  --master-only    Mount only Documents_1, the working SSD.
  --mirror-only    Mount only Documents_2, the backup HDD mirror.
  -h, --help       Show this help.

Config:
  ~/.config/dotfiles/document-shares.env

Defaults:
  Documents_1 -> /mnt/documents_1, read/write
  Documents_2 -> /mnt/documents_2, read-only on the client

Important:
  Work in Documents_1. Use Documents_2 only to inspect the mirror.
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --master-only)
      mount_master=1
      mount_mirror=0
      ;;
    --mirror-only)
      mount_master=0
      mount_mirror=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "mount-document-shares: unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

mount_one() {
  local share_name="$1"
  local mount_point="$2"
  local extra_options="$3"
  local credentials_file="${SMB_CREDENTIALS_FILE:-}"
  local smb_version="${SMB_VERSION:-3.0}"
  local smb_uid="${SMB_UID:-$(id -u)}"
  local smb_gid="${SMB_GID:-$(id -g)}"

  if [ -z "$share_name" ]; then
    return 0
  fi

  echo "==> Mounting //$SMB_HOST/$share_name -> $mount_point"
  if ! \
    SMB_CREDENTIALS_FILE="$credentials_file" \
    SMB_VERSION="$smb_version" \
    SMB_UID="$smb_uid" \
    SMB_GID="$smb_gid" \
    SMB_EXTRA_OPTIONS="$extra_options" \
    "$SCRIPT_DIR/mount-smb-share.sh" "//$SMB_HOST/$share_name" "$mount_point"; then
    echo "mount-document-shares: failed to mount //$SMB_HOST/$share_name at $mount_point" >&2
    return 1
  fi
}

if [ "$mount_master" -eq 1 ]; then
  mount_one "$DOCUMENTS_1_SHARE" "$DOCUMENTS_1_MOUNT" "$DOCUMENTS_1_MOUNT_OPTIONS"
fi

if [ "$mount_mirror" -eq 1 ]; then
  mirror_options="$DOCUMENTS_2_MOUNT_OPTIONS"
  if [ "$DOCUMENTS_2_CLIENT_READONLY" = "1" ] && [ -z "$mirror_options" ]; then
    mirror_options="ro"
  fi
  mount_one "$DOCUMENTS_2_SHARE" "$DOCUMENTS_2_MOUNT" "$mirror_options"
fi

echo "Document shares mounted."
echo "Work in:  $DOCUMENTS_1_MOUNT"
echo "Inspect:  $DOCUMENTS_2_MOUNT"
