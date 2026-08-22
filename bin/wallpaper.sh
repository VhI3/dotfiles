#!/bin/bash
set -euo pipefail

# Set wallpaper on all Wayland outputs via swaymsg.
# Usage: wallpaper.sh [path/to/image]
#        wallpaper.sh --theme <latte|frappe|macchiato|mocha>

SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
DOTFILES_DIR="$(cd "$(dirname "$SCRIPT_PATH")/.." && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
WALLPAPER_STATE_DIR="$CONFIG_HOME/wallpaper"
WALLPAPER_THEME_FILE="$WALLPAPER_STATE_DIR/theme.local"

default_theme() {
    printf '%s\n' "mocha"
}

current_theme() {
    if [ -f "$WALLPAPER_THEME_FILE" ]; then
        head -n 1 "$WALLPAPER_THEME_FILE"
    else
        default_theme
    fi
}

first_existing() {
    local candidate
    for candidate in "$@"; do
        if [ -f "$candidate" ]; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done
    return 1
}

wallpaper_for_theme() {
    case "$1" in
        latte)
            first_existing \
                "$DOTFILES_DIR/assets/wallpapers/catppuccin-latte.png"
            ;;
        frappe)
            first_existing \
                "$DOTFILES_DIR/assets/wallpapers/catppuccin-frappe.jpg"
            ;;
        macchiato)
            first_existing \
                "$DOTFILES_DIR/assets/wallpapers/catppuccin-macchiato.jpg"
            ;;
        mocha|*)
            first_existing \
                "$DOTFILES_DIR/assets/wallpapers/catppuccin-mocha.jpg" \
                "$DOTFILES_DIR/assets/wallpapers/keyboard-2.png"
            ;;
    esac
}

mkdir -p "$WALLPAPER_STATE_DIR"

if [ "${1:-}" = "--theme" ]; then
    if [ -z "${2:-}" ]; then
        echo "Usage: wallpaper.sh --theme <latte|frappe|macchiato|mocha>" >&2
        exit 1
    fi
    printf '%s\n' "$2" >"$WALLPAPER_THEME_FILE"
    WALLPAPER="$(wallpaper_for_theme "$2")"
elif [ -n "${1:-}" ]; then
    WALLPAPER="$1"
else
    WALLPAPER="$(wallpaper_for_theme "$(current_theme)")"
fi

if [ ! -f "$WALLPAPER" ]; then
    notify-send -u critical "Wallpaper" "No wallpaper found for $(basename "$WALLPAPER")."
    exit 1
fi

pkill swaybg >/dev/null 2>&1 || true
nohup swaybg -i "$WALLPAPER" -m fill >/dev/null 2>&1 &

notify-send -h string:x-canonical-private-synchronous:wallpaper \
    "Wallpaper" "$(basename "$WALLPAPER")"
