#!/bin/bash
set -euo pipefail

EPOS_PATTERN="${EPOS_PATTERN:-DSEA A/S EPOS BTD 900c Consumer Control}"
last_state=""

is_connected() {
    grep -Fq "$EPOS_PATTERN" /proc/bus/input/devices 2>/dev/null
}

notify_state() {
    local state="$1"
    local title="EPOS Dongle"
    local body=""

    case "$state" in
        connected)
            body="Connected"
            ;;
        disconnected)
            body="Disconnected"
            ;;
        *)
            return 0
            ;;
    esac

    notify-send \
        -h string:x-canonical-private-synchronous:epos-dongle \
        -u low \
        "$title" \
        "$body"
}

while sleep 1; do
    if is_connected; then
        current_state="connected"
    else
        current_state="disconnected"
    fi

    if [ -z "$last_state" ]; then
        last_state="$current_state"
        continue
    fi

    if [ "$current_state" != "$last_state" ]; then
        notify_state "$current_state"
        last_state="$current_state"
    fi
done
