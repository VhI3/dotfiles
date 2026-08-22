#!/usr/bin/env bash
set -euo pipefail

CREDENTIALS_FILE="${SMB_CREDENTIALS_FILE:-$HOME/.smb/media-server}"
SMB_VERSION="${SMB_VERSION:-3.0}"
SMB_EXTRA_OPTIONS="${SMB_EXTRA_OPTIONS:-}"
UID_VALUE="${SMB_UID:-$(id -u)}"
GID_VALUE="${SMB_GID:-$(id -g)}"

run_as_root() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    else
        sudo "$@"
    fi
}

usage() {
    cat <<'EOF'
Usage: mount-smb-share //<host>/<share> [mountpoint-or-name]

Examples:
  mount-smb-share "//server.local/Filme" filme
  mount-smb-share "//server.local/Series" /mnt/tv_show

Defaults:
  credentials file: ~/.smb/media-server
  SMB version:      3.0
  extra options:    optional via SMB_EXTRA_OPTIONS

Credential file format:
  username=your-user
  password=your-password
EOF
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    usage
    exit 0
fi

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    usage >&2
    exit 1
fi

share="$1"
mount_arg="${2:-}"

if [[ "$share" != //*/* ]]; then
    echo "mount-smb-share: share must look like //<host>/<share>" >&2
    exit 1
fi

if [ ! -f "$CREDENTIALS_FILE" ]; then
    echo "mount-smb-share: credentials file not found: $CREDENTIALS_FILE" >&2
    exit 1
fi

if [ -z "$mount_arg" ]; then
    share_name="${share##*/}"
    safe_name="$(printf '%s' "$share_name" | tr '[:upper:]' '[:lower:]' | sed 's/[[:space:]]\+/_/g')"
    mount_point="/mnt/$safe_name"
elif [[ "$mount_arg" = /* ]]; then
    mount_point="$mount_arg"
else
    mount_point="/mnt/$mount_arg"
fi

if mount | grep -Fq " on $mount_point "; then
    echo "$mount_point is already mounted."
    exit 0
fi

run_as_root mkdir -p "$mount_point"
mount_options="credentials=$CREDENTIALS_FILE,uid=$UID_VALUE,gid=$GID_VALUE,iocharset=utf8,vers=$SMB_VERSION"
if [ -n "$SMB_EXTRA_OPTIONS" ]; then
    mount_options="$mount_options,$SMB_EXTRA_OPTIONS"
fi

run_as_root mount -t cifs "$share" "$mount_point" \
    -o "$mount_options"

echo "Mounted $share at $mount_point"
