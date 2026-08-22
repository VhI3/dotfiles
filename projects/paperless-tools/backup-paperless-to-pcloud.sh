#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
. "$SCRIPT_DIR/paperless-tools.lib.sh"
paperless_load_config

safe_target() {
    local target="$1"

    case "$target" in
        ""|"/"|"/home"|"/media"|"$HOME")
            echo "Refusing unsafe backup target: $target" >&2
            return 1
            ;;
    esac

    case "$target" in
        "$HOME"/pCloudDrive/*|/media/"$USER"/*)
            return 0
            ;;
        *)
            echo "Refusing backup target outside approved roots: $target" >&2
            return 1
            ;;
    esac
}

sync_export() {
    local source_dir="$1"
    local target_dir="$2"

    safe_target "$target_dir"
    mkdir -p "$target_dir"

    echo "==> Syncing export to: $target_dir"
    rsync -av --delete "$source_dir"/ "$target_dir"/
}

target_is_ready() {
    local target="$1"
    local mount_root=""

    [ -n "$target" ] || return 1

    case "$target" in
        "$HOME"/pCloudDrive/*)
            [ -d "$HOME/pCloudDrive" ]
            return
            ;;
        /media/"$USER"/*)
            mount_root="$(printf '%s\n' "$target" | cut -d/ -f1-4)"
            mountpoint -q "$mount_root"
            return
            ;;
        *)
            return 1
            ;;
    esac
}

sync_export_if_ready() {
    local source_dir="$1"
    local target_dir="$2"
    local label="$3"

    if [ -z "$target_dir" ]; then
        echo "==> Skipping $label backup: no target configured"
        return 0
    fi

    if ! target_is_ready "$target_dir"; then
        echo "==> Skipping $label backup: target is not ready: $target_dir"
        return 0
    fi

    sync_export "$source_dir" "$target_dir"
}

echo "==> Paperless backup helper"
echo "Compose dir:  $PAPERLESS_COMPOSE_DIR"
echo "Export dir:   $PAPERLESS_EXPORT_DIR"
echo "pCloud target:$PCLOUD_BACKUP_TARGET"
echo "SSD target:   $SSD_BACKUP_TARGET"

if [ ! -d "$PAPERLESS_COMPOSE_DIR" ]; then
    echo "Error: Paperless compose directory not found: $PAPERLESS_COMPOSE_DIR" >&2
    exit 1
fi

compose_file="$(paperless_compose_file || true)"
if [ -z "$compose_file" ]; then
    echo "Error: no compose file found in $PAPERLESS_COMPOSE_DIR" >&2
    exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
    echo "Error: docker is not installed or not in PATH." >&2
    exit 1
fi

mkdir -p "$PAPERLESS_EXPORT_DIR"

echo "==> Running Paperless document_exporter"
(
    cd "$PAPERLESS_COMPOSE_DIR"
    docker compose ps >/dev/null
    docker compose exec -T webserver document_exporter -d -p "$PAPERLESS_EXPORT_CONTAINER_DIR"
)

if [ ! -d "$PAPERLESS_EXPORT_DIR" ]; then
    echo "Error: export directory was not created: $PAPERLESS_EXPORT_DIR" >&2
    exit 1
fi

sync_export_if_ready "$PAPERLESS_EXPORT_DIR" "$PCLOUD_BACKUP_TARGET" "pCloud"
sync_export_if_ready "$PAPERLESS_EXPORT_DIR" "$SSD_BACKUP_TARGET" "external SSD"

echo "==> Backup complete"
echo "Paperless export sync run finished."
