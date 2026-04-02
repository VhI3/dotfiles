#!/bin/bash
set -euo pipefail

PLAYER="${PLAYER:-spotify}"
ACTION="${1:-}"

if [ -z "$ACTION" ]; then
    echo "Usage: notify-media.sh <play-pause|next|previous>" >&2
    exit 1
fi

playerctl -p "$PLAYER" "$ACTION" >/dev/null 2>&1 || exit 0

status="$(playerctl -p "$PLAYER" status 2>/dev/null || true)"
title="$(playerctl -p "$PLAYER" metadata xesam:title 2>/dev/null || true)"
artist="$(playerctl -p "$PLAYER" metadata xesam:artist 2>/dev/null | paste -sd ', ' - || true)"

if [ -z "$title" ]; then
    title="No track information"
fi

if [ -n "$artist" ]; then
    body="$artist"
else
    body="$PLAYER"
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
