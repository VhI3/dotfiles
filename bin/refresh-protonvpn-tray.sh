#!/usr/bin/env bash
set -euo pipefail

# Re-register ProtonVPN with the tray after Waybar restarts.
# If ProtonVPN is not already running, do nothing.

app_pattern='/usr/bin/protonvpn-app'
log_file="${XDG_RUNTIME_DIR:-/tmp}/protonvpn-tray-refresh.log"

if ! pgrep -f "$app_pattern" >/dev/null 2>&1; then
    exit 0
fi

# Let Waybar recreate the tray first.
sleep 2

pkill -f "$app_pattern" >/dev/null 2>&1 || true

for _ in 1 2 3 4 5; do
    if ! pgrep -f "$app_pattern" >/dev/null 2>&1; then
        break
    fi
    sleep 0.2
done

if command -v setsid >/dev/null 2>&1; then
    setsid -f protonvpn-app >>"$log_file" 2>&1
else
    nohup protonvpn-app >>"$log_file" 2>&1 &
fi
