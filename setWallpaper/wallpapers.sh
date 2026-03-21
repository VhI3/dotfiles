#!/bin/bash
# wallpapers.sh — set wallpaper on all Wayland outputs via swaymsg
# Usage: wallpapers.sh [path/to/image]
# Falls back to artWork/dracula-spooky if no argument given

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEFAULT_WALLPAPER="$DOTFILES_DIR/artWork/dracula-spooky-6272a4.png"

WALLPAPER="${1:-$DEFAULT_WALLPAPER}"

if [ ! -f "$WALLPAPER" ]; then
    notify-send -u critical "wallpapers.sh" "File not found: $WALLPAPER"
    exit 1
fi

# Apply to all outputs
swaymsg output '*' bg "$WALLPAPER" fill

notify-send -h string:x-canonical-private-synchronous:wallpaper \
    "Wallpaper" "$(basename "$WALLPAPER")"
