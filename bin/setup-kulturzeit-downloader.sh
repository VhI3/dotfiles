#!/usr/bin/env bash
set -euo pipefail

CONFIG_ENV="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/kulturzeit-downloader.env"
DOTFILES_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.." && pwd)"

if [ -f "$CONFIG_ENV" ]; then
    # shellcheck disable=SC1090
    . "$CONFIG_ENV"
fi

APP_DIR="${KULTURZEIT_DOWNLOADER_DIR:-$HOME/dev/kulturzeit-downloader}"
VENV_DIR="${KULTURZEIT_VENV_DIR:-$APP_DIR/.venv}"
CONFIG_FILE="${KULTURZEIT_CONFIG_FILE:-$APP_DIR/config.toml}"
DOWNLOAD_DIR="${KULTURZEIT_DOWNLOAD_DIR:-/mnt/tv_show/Kulturzeit}"
DOWNLOAD_MOUNT_POINT="${KULTURZEIT_DOWNLOAD_MOUNT_POINT:-/mnt/tv_show}"

force_config=0
install_deps=1

usage() {
    cat <<EOF
Usage:
  setup-kulturzeit-downloader [options]

Prepare the Kulturzeit downloader after a fresh Debian restore.

Options:
  --force-config   Rewrite config.toml even if it already exists.
  --no-deps        Do not create/update the Python virtualenv.
  -h, --help       Show this help.

Expected project:
  $APP_DIR

Config written to:
  $CONFIG_FILE
EOF
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --force-config)
            force_config=1
            ;;
        --no-deps)
            install_deps=0
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "setup-kulturzeit-downloader: unknown option: $1" >&2
            usage >&2
            exit 2
            ;;
    esac
    shift
done

if [ ! -f "$APP_DIR/kulturzeit_downloader.py" ]; then
    cat >&2 <<EOF
setup-kulturzeit-downloader: project not found:
  $APP_DIR

Restore the downloader project first. The dotfiles manage the launcher,
virtualenv and config, but not the project source itself.
EOF
    exit 1
fi

if [ "$install_deps" -eq 1 ]; then
    if ! command -v python3 >/dev/null 2>&1; then
        echo "setup-kulturzeit-downloader: python3 is missing." >&2
        exit 1
    fi
    python3 -m venv "$VENV_DIR"
    "$VENV_DIR/bin/python" -m pip install --upgrade pip
    "$VENV_DIR/bin/python" -m pip install -r "$APP_DIR/requirements.txt"
fi

if [ ! -f "$CONFIG_FILE" ] || [ "$force_config" -eq 1 ]; then
    cat >"$CONFIG_FILE" <<EOF
[kulturzeit]
# Ziel ist die auf dem Debian-Laptop gemountete Jellyfin-Serienfreigabe.
# Vor dem Download muss mount-media-shares gelaufen sein.
download_dir = "$DOWNLOAD_DIR"
download_mount_point = "$DOWNLOAD_MOUNT_POINT"

search_previous_month_to_today = true
search_days = 10
cleanup_enabled = false
retention_days = 30
min_duration_minutes = 30
max_duration_minutes = 60
max_results = 100
http_timeout_seconds = 30
log_to_file = true
EOF
    echo "==> Wrote $CONFIG_FILE"
else
    echo "==> Keeping existing $CONFIG_FILE"
fi

mkdir -p "$HOME/.local/bin"
ln -sfn "$DOTFILES_DIR/bin/kulturzeit-downloader.sh" "$HOME/.local/bin/kulturzeit-downloader"

cat <<EOF

Kulturzeit downloader is ready.

Run:
  kulturzeit-downloader --dry-run
  kulturzeit-downloader

Target:
  $DOWNLOAD_DIR
EOF
