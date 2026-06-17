#!/usr/bin/env bash
set -euo pipefail

run_as_root() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    else
        sudo "$@"
    fi
}

usage() {
    cat <<'EOF'
Usage: mount-ntfs /dev/sdXN [mountpoint-or-name]

Examples:
  mount-ntfs /dev/sda1 oneTB
  mount-ntfs /dev/sdc1 /mnt/oneTB
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

device="$1"
mount_arg="${2:-ntfsdisk}"

if [ ! -b "$device" ]; then
    echo "mount-ntfs: device not found: $device" >&2
    exit 1
fi

if [[ "$mount_arg" = /* ]]; then
    mount_point="$mount_arg"
else
    mount_point="/mnt/$mount_arg"
fi

if mount | grep -Fq "$device on "; then
    echo "$device is already mounted."
    exit 0
fi

run_as_root mkdir -p "$mount_point"
run_as_root mount -t ntfs-3g "$device" "$mount_point"

echo "Mounted $device at $mount_point"
