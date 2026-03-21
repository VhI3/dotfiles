#!/bin/bash
set -euo pipefail

# Set wallpaper on all Wayland outputs via swaymsg.
# Usage: wallpaper.sh [path/to/image]

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEFAULT_WALLPAPER="$DOTFILES_DIR/assets/wallpapers/dracula-spooky-6272a4.png"
WALLPAPER="${1:-$DEFAULT_WALLPAPER}"

if [ ! -f "$WALLPAPER" ]; then
    WALLPAPER="$DEFAULT_WALLPAPER"
fi

if [ ! -f "$WALLPAPER" ]; then
    notify-send -u critical "Wallpaper" "No wallpaper found."
    exit 1
fi

swaymsg output '*' bg "$WALLPAPER" fill >/dev/null

notify-send -h string:x-canonical-private-synchronous:wallpaper \
    "Wallpaper" "$(basename "$WALLPAPER")"
