#!/bin/bash
set -euo pipefail

MOUNT_POINT="${MOUNT_POINT:-/mnt/sdcard}"
DEVICE="${1:-}"

find_device() {
    lsblk -rpo NAME,TYPE,RM,TRAN |
        awk '
            $2 == "part" && ($3 == "1" || $4 == "mmc") { print $1; exit }
        '
}

if [ -z "$DEVICE" ]; then
    DEVICE="$(find_device || true)"
fi

if [ -z "$DEVICE" ]; then
    echo "No removable partition found."
    echo "Usage: mount-sd /dev/mmcblk0p1"
    exit 1
fi

if [ ! -b "$DEVICE" ]; then
    echo "Device not found: $DEVICE"
    exit 1
fi

if mount | grep -q "^$DEVICE on "; then
    echo "$DEVICE is already mounted."
    exit 0
fi

sudo mkdir -p "$MOUNT_POINT"
sudo mount "$DEVICE" "$MOUNT_POINT"

echo "Mounted $DEVICE at $MOUNT_POINT"
