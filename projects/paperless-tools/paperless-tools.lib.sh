#!/usr/bin/env bash
set -euo pipefail

PAPERLESS_TOOLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PAPERLESS_TOOLS_CONFIG="${PAPERLESS_TOOLS_CONFIG:-$PAPERLESS_TOOLS_DIR/paperless-tools.conf}"
PAPERLESS_TOOLS_LOCAL_CONFIG="${PAPERLESS_TOOLS_LOCAL_CONFIG:-${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/paperless-tools.local.conf}"
PAPERLESS_TOOLS_REPO_LOCAL_CONFIG="$PAPERLESS_TOOLS_DIR/paperless-tools.local.conf"

paperless_find_compose_dir() {
    local candidate

    for candidate in \
        "${PAPERLESS_COMPOSE_DIR:-}" \
        "$HOME/paperless-ngx" \
        "$HOME/Projects/paperless-ngx" \
        "$HOME/projects/paperless-ngx" \
        "$HOME/docker/paperless-ngx"
    do
        [ -n "$candidate" ] || continue
        if [ -d "$candidate" ]; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done

    printf '%s\n' "$HOME/paperless-ngx"
}

paperless_load_config() {
    PAPERLESS_CONSUME_DIR="${PAPERLESS_CONSUME_DIR:-$HOME/Documents/Scan-Inbox}"
    SCAN_INBOX="${SCAN_INBOX:-$PAPERLESS_CONSUME_DIR}"
    PAPERLESS_CONSUME_MOUNT="${PAPERLESS_CONSUME_MOUNT:-}"
    PAPERLESS_CONSUME_MUST_BE_MOUNTED="${PAPERLESS_CONSUME_MUST_BE_MOUNTED:-0}"
    PAPERLESS_CONSUME_ALLOW_CREATE="${PAPERLESS_CONSUME_ALLOW_CREATE:-0}"
    PAPERLESS_CONSUME_SMB_SHARE="${PAPERLESS_CONSUME_SMB_SHARE:-}"
    PAPERLESS_SMB_CREDENTIALS_FILE="${PAPERLESS_SMB_CREDENTIALS_FILE:-}"
    NAPS2_PROFILE_NAME="${NAPS2_PROFILE_NAME:-}"
    NAPS2_PROFILES_XML="${NAPS2_PROFILES_XML:-$HOME/.config/naps2/profiles.xml}"

    PAPERLESS_COMPOSE_DIR="$(paperless_find_compose_dir)"
    PAPERLESS_SERVER_ONLY="${PAPERLESS_SERVER_ONLY:-0}"
    PAPERLESS_URL="${PAPERLESS_URL:-http://127.0.0.1:8000}"
    PAPERLESS_USERNAME="${PAPERLESS_USERNAME:-$USER}"
    PAPERLESS_OCR_LANGUAGE="${PAPERLESS_OCR_LANGUAGE:-deu+eng}"
    PAPERLESS_EXPORT_CONTAINER_DIR="${PAPERLESS_EXPORT_CONTAINER_DIR:-/usr/src/paperless/export}"
    PAPERLESS_EXPORT_DIR="${PAPERLESS_EXPORT_DIR:-$PAPERLESS_COMPOSE_DIR/export}"

    PCLOUD_BACKUP_TARGET="${PCLOUD_BACKUP_TARGET:-$HOME/pCloudDrive/Document/Paperless-Backup}"
    SSD_BACKUP_TARGET="${SSD_BACKUP_TARGET:-/media/$USER/Documents_1/20-Referenz/paperless-export}"

    if [ -f "$PAPERLESS_TOOLS_CONFIG" ]; then
        # shellcheck disable=SC1090
        . "$PAPERLESS_TOOLS_CONFIG"
    fi

    if [ -f "$PAPERLESS_TOOLS_LOCAL_CONFIG" ]; then
        # shellcheck disable=SC1090
        . "$PAPERLESS_TOOLS_LOCAL_CONFIG"
    elif [ -f "$PAPERLESS_TOOLS_REPO_LOCAL_CONFIG" ]; then
        # Backward-compatible fallback for older local setups.
        # shellcheck disable=SC1090
        . "$PAPERLESS_TOOLS_REPO_LOCAL_CONFIG"
    fi

    PAPERLESS_COMPOSE_DIR="$(paperless_find_compose_dir)"
    PAPERLESS_EXPORT_DIR="${PAPERLESS_EXPORT_DIR:-$PAPERLESS_COMPOSE_DIR/export}"
    PAPERLESS_CONSUME_DIR="${PAPERLESS_CONSUME_DIR:-$SCAN_INBOX}"
    SCAN_INBOX="${SCAN_INBOX:-$PAPERLESS_CONSUME_DIR}"
}

paperless_compose_file() {
    local dir="${1:-$PAPERLESS_COMPOSE_DIR}"
    local candidate

    for candidate in \
        "$dir/docker-compose.yml" \
        "$dir/docker-compose.yaml" \
        "$dir/compose.yml" \
        "$dir/compose.yaml"
    do
        if [ -f "$candidate" ]; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done

    return 1
}
