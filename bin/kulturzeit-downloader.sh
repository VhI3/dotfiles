#!/usr/bin/env bash
set -euo pipefail

CONFIG_ENV="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/kulturzeit-downloader.env"
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"

if [ -f "$CONFIG_ENV" ]; then
    # shellcheck disable=SC1090
    . "$CONFIG_ENV"
fi

APP_DIR="${KULTURZEIT_DOWNLOADER_DIR:-$HOME/dev/kulturzeit-downloader}"
VENV_DIR="${KULTURZEIT_VENV_DIR:-$APP_DIR/.venv}"
PYTHON="$VENV_DIR/bin/python"
SCRIPT="$APP_DIR/kulturzeit_downloader.py"
CONFIG_FILE="${KULTURZEIT_CONFIG_FILE:-$APP_DIR/config.toml}"
DOWNLOAD_MOUNT_POINT="${KULTURZEIT_DOWNLOAD_MOUNT_POINT:-/mnt/tv_show}"
AUTO_MOUNT_MEDIA="${KULTURZEIT_AUTO_MOUNT_MEDIA:-1}"

usage() {
    cat <<EOF
Usage:
  kulturzeit-downloader [options]
  kulturzeit-downloader --setup

Runs the Kulturzeit downloader from:
  $APP_DIR

Defaults:
  Config:       $CONFIG_FILE
  Server mount: $DOWNLOAD_MOUNT_POINT

Examples:
  kulturzeit-downloader
  kulturzeit-downloader --dry-run
  kulturzeit-downloader --setup

Wrapper options:
  --setup      Prepare venv/config/link for the downloader project.
  --app-dir    Print the downloader project directory.
  -h, --help   Show the Python program help.
EOF
}

has_config_arg() {
    local arg
    for arg in "$@"; do
        case "$arg" in
            --config|--config=*)
                return 0
                ;;
        esac
    done
    return 1
}

case "${1:-}" in
    --setup)
        shift
        if command -v setup-kulturzeit-downloader >/dev/null 2>&1; then
            exec setup-kulturzeit-downloader "$@"
        fi
        exec "$SCRIPT_DIR/setup-kulturzeit-downloader.sh" "$@"
        ;;
    --app-dir)
        printf '%s\n' "$APP_DIR"
        exit 0
        ;;
esac

if [ "${1:-}" = "--wrapper-help" ]; then
    usage
    exit 0
fi

if [ ! -f "$SCRIPT" ]; then
    cat >&2 <<EOF
kulturzeit-downloader: downloader script not found:
  $SCRIPT

Restore or clone the project first, then run:
  setup-kulturzeit-downloader
EOF
    exit 1
fi

if [ ! -x "$PYTHON" ]; then
    cat >&2 <<EOF
kulturzeit-downloader: virtualenv is missing:
  $VENV_DIR

Run:
  setup-kulturzeit-downloader
EOF
    exit 1
fi

if [ "$AUTO_MOUNT_MEDIA" = "1" ] && [ -n "$DOWNLOAD_MOUNT_POINT" ]; then
    if ! mountpoint -q "$DOWNLOAD_MOUNT_POINT"; then
        if command -v mount-media-shares >/dev/null 2>&1; then
            echo "==> $DOWNLOAD_MOUNT_POINT is not mounted; running mount-media-shares"
            mount-media-shares
        else
            echo "kulturzeit-downloader: mount-media-shares not found and $DOWNLOAD_MOUNT_POINT is not mounted." >&2
            exit 1
        fi
    fi
fi

cmd=("$PYTHON" "$SCRIPT")
if ! has_config_arg "$@" && [ -f "$CONFIG_FILE" ]; then
    cmd+=(--config "$CONFIG_FILE")
fi

exec "${cmd[@]}" "$@"
