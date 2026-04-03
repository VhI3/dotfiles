#!/bin/bash
set -euo pipefail

EPOS_PATTERN="${EPOS_PATTERN:-DSEA A/S EPOS BTD 900c Consumer Control}"
SWAY_CONFIG="${SWAY_CONFIG:-$HOME/.config/sway/config}"
NOTIFY_MEDIA="${HOME}/.local/bin/notify-media"

BLOCK_START="# BEGIN managed block: EPOS media keys"
BLOCK_END="# END managed block: EPOS media keys"
read -r -d '' BLOCK <<'EOF' || true
# BEGIN managed block: EPOS media keys
# Added by setup-epos.sh
bindsym --locked XF86AudioPlay exec $HOME/.local/bin/notify-media play-pause
bindsym --locked XF86AudioPause exec $HOME/.local/bin/notify-media play-pause
bindsym --locked XF86AudioNext exec $HOME/.local/bin/notify-media next
bindsym --locked XF86AudioPrev exec $HOME/.local/bin/notify-media previous
# END managed block: EPOS media keys
EOF

find_epos_event() {
    awk -v pattern="$EPOS_PATTERN" '
        BEGIN { RS=""; FS="\n" }
        $0 ~ pattern {
            for (i = 1; i <= NF; i++) {
                if ($i ~ /^H: Handlers=/) {
                    split($i, parts, " ")
                    for (j in parts) {
                        if (parts[j] ~ /^event[0-9]+$/) {
                            print "/dev/input/" parts[j]
                            exit
                        }
                    }
                }
            }
        }
    ' /proc/bus/input/devices
}

ensure_block() {
    local file="$1"
    local tmp

    if [ ! -f "$file" ]; then
        mkdir -p "$(dirname "$file")"
        printf '%s\n' "$BLOCK" >"$file"
        return 0
    fi

    if grep -Fq 'bindsym --locked XF86AudioPlay exec $HOME/.local/bin/notify-media play-pause' "$file" \
        && grep -Fq 'bindsym --locked XF86AudioPause exec $HOME/.local/bin/notify-media play-pause' "$file" \
        && grep -Fq 'bindsym --locked XF86AudioNext exec $HOME/.local/bin/notify-media next' "$file" \
        && grep -Fq 'bindsym --locked XF86AudioPrev exec $HOME/.local/bin/notify-media previous' "$file"; then
        echo "Sway media-key bindings are already present."
        return 0
    fi

    tmp="$(mktemp)"

    awk -v start="$BLOCK_START" -v end="$BLOCK_END" '
        $0 == start { skip = 1; next }
        $0 == end { skip = 0; next }
        !skip { print }
    ' "$file" >"$tmp"

    printf '\n%s\n' "$BLOCK" >>"$tmp"
    mv "$tmp" "$file"
}

echo "==> EPOS media key setup"

if ! command -v playerctl >/dev/null 2>&1; then
    echo "playerctl is not installed." >&2
    echo "Install it with: sudo apt install playerctl" >&2
    exit 1
fi

if [ ! -x "$NOTIFY_MEDIA" ]; then
    echo "notify-media helper not found at $NOTIFY_MEDIA" >&2
    echo "Run ./dots/link.sh first so the helper is linked into ~/.local/bin." >&2
    exit 1
fi

if [ ! -r /proc/bus/input/devices ]; then
    echo "Cannot read /proc/bus/input/devices to detect the EPOS dongle." >&2
    exit 1
fi

event_device="$(find_epos_event || true)"
if [ -n "$event_device" ]; then
    echo "Detected EPOS consumer-control device: $event_device"
else
    echo "EPOS consumer-control device not detected right now." >&2
    echo "The Sway bindings will still be installed, but plug in the dongle before testing." >&2
fi

ensure_block "$SWAY_CONFIG"

echo "Installed media-key bindings into: $SWAY_CONFIG"
echo "Reload Sway with: swaymsg reload"
echo
echo "After reloading, the EPOS buttons should control the active media player"
echo "through playerctl and show track notifications."
