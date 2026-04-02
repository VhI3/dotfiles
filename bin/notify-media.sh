#!/bin/bash
set -euo pipefail

ACTION="${1:-}"

if [ -z "$ACTION" ]; then
    echo "Usage: notify-media.sh <play-pause|next|previous>" >&2
    exit 1
fi

playerctl "$ACTION" >/dev/null 2>&1 || exit 0

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

notify-send \
    -h string:x-canonical-private-synchronous:media \
    -u low \
    "$summary" \
    "$body"
