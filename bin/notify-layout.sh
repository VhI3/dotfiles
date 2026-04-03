#!/bin/bash
set -euo pipefail

last=""

get_layout() {
    swaymsg -t get_inputs -r 2>/dev/null | python3 - <<'PY'
import json
import sys

try:
    data = json.load(sys.stdin)
except Exception:
    raise SystemExit(0)

for dev in data:
    name = dev.get("xkb_active_layout_name")
    if name:
        print(name)
        break
PY
}

format_layout() {
    case "$1" in
        *English*|*english*|us|US)
            printf 'EN'
            ;;
        *Persian*|*persian*|*Farsi*|*farsi*|ir|IR)
            printf 'IR'
            ;;
        *)
            printf '%s' "$1"
            ;;
    esac
}

while sleep 0.5; do
    current="$(get_layout || true)"
    [ -z "$current" ] && continue

    if [ -z "$last" ]; then
        last="$current"
        continue
    fi

    if [ "$current" != "$last" ]; then
        notify-send \
            -h string:x-canonical-private-synchronous:keyboard-layout \
            -u low \
            "Keyboard Layout" \
            "$(format_layout "$current")"
        last="$current"
    fi
done
