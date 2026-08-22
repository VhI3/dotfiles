#!/usr/bin/env bash
set -euo pipefail

document_env="${HOME}/.config/dotfiles/document-drives.env"
script_name="restic-documents-backup-service"

if [ -f "$document_env" ]; then
    # shellcheck disable=SC1090
    . "$document_env"
fi

src="${DOCUMENTS_SSD_MOUNT:-/media/$USER/Documents_1}"
dest="${DOCUMENTS_HDD_MOUNT:-/media/$USER/Documents_2}"
src_uuid="${DOCUMENTS_SSD_UUID:-}"
dest_uuid="${DOCUMENTS_HDD_UUID:-}"

log() {
    printf '%s: %s\n' "$script_name" "$*"
}

die() {
    printf '%s: ERROR: %s\n' "$script_name" "$*" >&2
    exit 1
}

skip() {
    printf '%s: backup skipped: %s\n' "$script_name" "$*"
    exit 0
}

mount_spec_for_target() {
    local target="$1"
    awk -v target="$target" '
        $0 !~ /^[[:space:]]*#/ && NF >= 2 && $2 == target { print $1; exit }
    ' /etc/fstab 2>/dev/null || true
}

device_for_mount() {
    local target="$1"
    local uuid="$2"
    local spec=""

    if [ -n "$uuid" ]; then
        printf '/dev/disk/by-uuid/%s\n' "$uuid"
        return 0
    fi

    spec="$(mount_spec_for_target "$target")"
    if [ -z "$spec" ]; then
        return 1
    fi

    case "$spec" in
        UUID=*)
            printf '/dev/disk/by-uuid/%s\n' "${spec#UUID=}"
            ;;
        LABEL=*)
            printf '/dev/disk/by-label/%s\n' "${spec#LABEL=}"
            ;;
        /dev/*)
            printf '%s\n' "$spec"
            ;;
        *)
            return 1
            ;;
    esac
}

try_mount_target() {
    local target="$1"
    local uuid="$2"
    local device=""

    if mountpoint -q "$target"; then
        return 0
    fi

    if ! command -v udisksctl >/dev/null 2>&1; then
        skip "destination is not mounted ($target), and automatic mounting is not available"
    fi

    if ! device="$(device_for_mount "$target" "$uuid")"; then
        skip "destination is not mounted ($target), and no matching backup device could be resolved"
    fi

    if [ ! -e "$device" ]; then
        skip "destination is not mounted ($target), and backup device is not connected"
    fi

    log "destination is not mounted; attempting auto-mount via udisksctl ($device)"
    if ! udisksctl mount -b "$device" >/dev/null 2>&1; then
        skip "automatic mount failed for backup device $device"
    fi

    sleep 1

    if ! mountpoint -q "$target"; then
        skip "backup device mounted unexpectedly; expected target $target"
    fi

    log "destination mounted successfully at $target"
}

if ! mountpoint -q "$src"; then
    skip "source is not mounted ($src); external document SSD is not connected"
fi

try_mount_target "$dest" "$dest_uuid"

log "source: $src"
log "destination: $dest"
log "phase 1/4: starting backup snapshot"
if ! "$HOME/.local/bin/restic-backup" backup; then
    die "backup step failed; run 'journalctl --user -u restic-documents-backup.service -n 50 --no-pager' for details"
fi
log "phase 1/4 complete: backup snapshot finished"

if pgrep -x restic >/dev/null 2>&1; then
    log "phase 2/4 skipped: another restic process is running; not starting unlock/forget"
    exit 0
fi

log "phase 2/4: clearing stale locks"
if ! "$HOME/.local/bin/restic-backup" unlock; then
    die "could not clear stale restic locks"
fi
log "phase 2/4 complete: stale lock cleanup finished"

log "phase 3/4: applying retention policy and prune"
if ! "$HOME/.local/bin/restic-backup" forget; then
    die "retention/prune step failed"
fi
log "phase 3/4 complete: retention policy applied"

log "phase 4/4: backup workflow finished successfully"
