#!/bin/bash
set -euo pipefail

ACTION="${1:-}"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/media-art"

if [ -z "$ACTION" ]; then
    echo "Usage: notify-media.sh <play-pause|next|previous>" >&2
    exit 1
fi

mkdir -p "$CACHE_DIR"

resolve_art_icon() {
    local art_url cache_key cache_file

    art_url="$(playerctl metadata mpris:artUrl 2>/dev/null || true)"
    [ -n "$art_url" ] || return 1

    case "$art_url" in
        file://*)
            python3 - <<'PY' "$art_url"
import sys
from urllib.parse import unquote, urlparse

url = sys.argv[1]
path = unquote(urlparse(url).path)
print(path)
PY
            ;;
        http://*|https://*)
            cache_key="$(printf '%s' "$art_url" | sha256sum | awk '{print $1}')"
            cache_file="$CACHE_DIR/$cache_key"
            if [ ! -s "$cache_file" ]; then
                curl -fsSL "$art_url" -o "$cache_file" || return 1
            fi
            printf '%s\n' "$cache_file"
            ;;
        /*)
            printf '%s\n' "$art_url"
            ;;
        *)
            return 1
            ;;
    esac
}

status_before="$(playerctl status 2>/dev/null || true)"
title_before="$(playerctl metadata xesam:title 2>/dev/null || true)"

playerctl "$ACTION" >/dev/null 2>&1 || exit 0

if [ "$ACTION" = "next" ] || [ "$ACTION" = "previous" ]; then
    for _ in 1 2 3 4 5; do
        sleep 0.15
        title_now="$(playerctl metadata xesam:title 2>/dev/null || true)"
        if [ -n "$title_now" ] && [ "$title_now" != "$title_before" ]; then
            break
        fi
    done
fi

status="$(playerctl status 2>/dev/null || true)"
title="$(playerctl metadata xesam:title 2>/dev/null || true)"
artist="$(playerctl metadata xesam:artist 2>/dev/null | paste -sd ', ' - || true)"
player_name="$(playerctl metadata --format '{{playerName}}' 2>/dev/null || true)"

if [ -z "$title" ]; then
    title="No track information"
fi

if [ -n "$artist" ]; then
    body="$artist"
elif [ -n "$player_name" ]; then
    body="$player_name"
else
    body="media"
fi

icon_path="$(resolve_art_icon || true)"
notify_args=()
if [ -n "$icon_path" ] && [ -f "$icon_path" ]; then
    notify_args=(-i "$icon_path")
fi

case "$status" in
    Playing)
        summary="Playing: $title"
        ;;
    Paused)
        summary="Paused: $title"
        ;;
    *)
        summary="$title"
        ;;
esac

case "$ACTION" in
    next)
        summary="Next: $title"
        ;;
    previous)
        summary="Previous: $title"
        ;;
    play-pause)
        if [ "$status_before" = "Playing" ]; then
            summary="Pause: $title"
        elif [ "$status_before" = "Paused" ] || [ "$status_before" = "Stopped" ]; then
            summary="Play: $title"
        elif [ "$status" = "Paused" ]; then
            summary="Pause: $title"
        else
            summary="Play: $title"
        fi
        ;;
esac

notify-send \
    -h string:x-canonical-private-synchronous:media \
    -u low \
    "${notify_args[@]}" \
    "$summary" \
    "$body"
