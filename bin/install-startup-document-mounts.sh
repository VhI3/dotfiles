#!/usr/bin/env bash
set -euo pipefail

FSTAB_FILE="/etc/fstab"
document_env="${HOME}/.config/dotfiles/document-drives.env"

if [ -f "$document_env" ]; then
    # shellcheck disable=SC1090
    . "$document_env"
fi

MOUNT_1="${DOCUMENTS_SSD_MOUNT:-/media/$USER/Documents_1}"
MOUNT_2="${DOCUMENTS_HDD_MOUNT:-/media/$USER/Documents_2}"
UUID_1="${DOCUMENTS_SSD_UUID:-}"
UUID_2="${DOCUMENTS_HDD_UUID:-}"

usage() {
    cat <<'EOF'
Usage: install-startup-document-mounts [--apply]

Install /etc/fstab entries so your document SSD and HDD mount automatically at boot.

Default mode is dry-run. Use --apply to write changes.
EOF
}

apply=0

while [ $# -gt 0 ]; do
    case "$1" in
        --apply)
            apply=1
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
    shift
done

entry_1="UUID=$UUID_1 $MOUNT_1 ext4 defaults,nofail,x-systemd.device-timeout=5s 0 2"
entry_2="UUID=$UUID_2 $MOUNT_2 ext4 defaults,nofail,x-systemd.device-timeout=5s 0 2"

if [ -z "$UUID_1" ] || [ -z "$UUID_2" ]; then
    echo "Missing DOCUMENTS_SSD_UUID or DOCUMENTS_HDD_UUID." >&2
    echo "Set them in ~/.config/dotfiles/document-drives.env or export them before running this script." >&2
    exit 1
fi

show_plan() {
    printf 'Would ensure mountpoints exist:\n'
    printf '  %s\n' "$MOUNT_1"
    printf '  %s\n' "$MOUNT_2"
    printf '\nWould ensure these /etc/fstab entries exist:\n'
    printf '  %s\n' "$entry_1"
    printf '  %s\n' "$entry_2"
}

ensure_line() {
    local line="$1"
    if sudo grep -Fqx "$line" "$FSTAB_FILE"; then
        printf 'Already present: %s\n' "$line"
    else
        printf '%s\n' "$line" | sudo tee -a "$FSTAB_FILE" >/dev/null
        printf 'Added: %s\n' "$line"
    fi
}

if [ "$apply" -eq 0 ]; then
    show_plan
    exit 0
fi

sudo mkdir -p "$MOUNT_1" "$MOUNT_2"
ensure_line "$entry_1"
ensure_line "$entry_2"
sudo mount -a

printf '\nMounted status:\n'
findmnt "$MOUNT_1" "$MOUNT_2" || true
