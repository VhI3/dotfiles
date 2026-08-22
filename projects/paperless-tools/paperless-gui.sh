#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
. "$SCRIPT_DIR/paperless-tools.lib.sh"
paperless_load_config

TITLE="Paperless Tools"
LOCAL_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/paperless-tools.local.conf"

need_cmd() {
    if ! command -v "$1" >/dev/null 2>&1; then
        zenity --error \
            --title="$TITLE" \
            --text="Required command not found: $1"
        exit 1
    fi
}

need_cmd zenity

show_text() {
    local title="$1"
    local file="$2"

    zenity --text-info \
        --title="$title" \
        --filename="$file" \
        --width=900 \
        --height=650
}

run_action() {
    local label="$1"
    shift

    local output_file
    output_file="$(mktemp)"

    local exit_file
    exit_file="$(mktemp)"

    (
        if "$@" >"$output_file" 2>&1; then
            printf '0' >"$exit_file"
        else
            printf '%s' "$?" >"$exit_file"
        fi
    ) &
    local cmd_pid=$!

    (
        echo 5
        echo "# $label"
        while kill -0 "$cmd_pid" >/dev/null 2>&1; do
            echo 5
            echo "# $label"
            sleep 1
        done
        echo 100
    ) | zenity --progress \
        --title="$TITLE" \
        --text="$label" \
        --pulsate \
        --auto-close \
        --no-cancel \
        --width=420 >/dev/null 2>&1 || true

    wait "$cmd_pid" || true

    local status
    status="$(cat "$exit_file")"
    rm -f "$exit_file"

    if [ "$status" -eq 0 ]; then
        show_text "$TITLE - $label" "$output_file"
    else
        zenity --error \
            --title="$TITLE" \
            --width=700 \
            --text="$label failed"
        show_text "$TITLE - $label (Error)" "$output_file"
    fi

    rm -f "$output_file"
}

open_path() {
    local target="$1"
    if command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$target" >/dev/null 2>&1 &
    else
        zenity --error --title="$TITLE" --text="xdg-open is not available."
    fi
}

show_paths() {
    local file
    file="$(mktemp)"
    {
        printf 'Paperless URL:        %s\n' "$PAPERLESS_URL"
        printf 'Consume directory:    %s\n' "$PAPERLESS_CONSUME_DIR"
        printf 'Export directory:     %s\n' "$PAPERLESS_EXPORT_DIR"
        printf 'pCloud backup target: %s\n' "$PCLOUD_BACKUP_TARGET"
        printf 'SSD backup target:    %s\n' "$SSD_BACKUP_TARGET"
        printf 'Compose directory:    %s\n' "$PAPERLESS_COMPOSE_DIR"
        printf 'NAPS2 profile:        %s\n' "${NAPS2_PROFILE_NAME:-<most recently used GUI profile>}"
        printf 'Local config:         %s\n' "$LOCAL_CONFIG"
    } >"$file"
    show_text "$TITLE - Current Paths" "$file"
    rm -f "$file"
}

mkdir -p "$(dirname "$LOCAL_CONFIG")"

while true; do
    paperless_load_config

    choice="$(
        zenity --list \
            --title="$TITLE" \
            --text="Choose a Paperless action" \
            --column="Action" \
            --width=520 \
            --height=420 \
            "Smart scan: duplex then glass" \
            "Check Paperless" \
            "List NAPS2 profiles" \
            "Backup Paperless export" \
            "Open Paperless in browser" \
            "Open consume folder" \
            "Show current paths" \
            "Edit local config" \
            "Quit"
    )" || exit 0

    case "$choice" in
        "Smart scan: duplex then glass")
            run_action "Scanning document" "$SCRIPT_DIR/scan-to-paperless.sh"
            ;;
        "Check Paperless")
            run_action "Checking Paperless" "$SCRIPT_DIR/check-paperless.sh"
            ;;
        "List NAPS2 profiles")
            run_action "Listing NAPS2 profiles" "$SCRIPT_DIR/list-naps2-profiles.sh"
            ;;
        "Backup Paperless export")
            run_action "Backing up Paperless export" "$SCRIPT_DIR/backup-paperless-to-pcloud.sh"
            ;;
        "Open Paperless in browser")
            open_path "$PAPERLESS_URL"
            ;;
        "Open consume folder")
            open_path "$PAPERLESS_CONSUME_DIR"
            ;;
        "Show current paths")
            show_paths
            ;;
        "Edit local config")
            if [ ! -f "$LOCAL_CONFIG" ]; then
                cp "$SCRIPT_DIR/paperless-tools.local.conf.example" "$LOCAL_CONFIG"
            fi
            open_path "$LOCAL_CONFIG"
            ;;
        "Quit")
            exit 0
            ;;
    esac
done
