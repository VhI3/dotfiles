#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
. "$SCRIPT_DIR/paperless-tools.lib.sh"
paperless_load_config

echo "==> NAPS2 profiles"
echo

if [ -f "$NAPS2_PROFILES_XML" ]; then
    profile_names="$(sed -n 's:.*<DisplayName>\(.*\)</DisplayName>.*:\1:p' "$NAPS2_PROFILES_XML")"
    if [ -n "$profile_names" ]; then
        printf '%s\n' "$profile_names" | nl -w2 -s'. '
    else
        echo "No profile display names were found in $NAPS2_PROFILES_XML."
    fi
else
    echo "No NAPS2 profiles file found at $NAPS2_PROFILES_XML."
fi

echo
echo "==> Scanner devices reported by NAPS2"
echo

if ! command -v naps2 >/dev/null 2>&1; then
    echo "Error: naps2 is not installed or not in PATH." >&2
    exit 1
fi

for driver in sane escl; do
    echo "-- driver: $driver --"
    if ! timeout 12s naps2 console --listdevices --driver "$driver"; then
        echo "No devices reported for driver: $driver (or detection timed out)"
    fi
    echo
done

cat <<'EOF'
Note:
- NAPS2 does not expose a direct "list profiles" console command here.
- This helper reads local profile names from ~/.config/naps2/profiles.xml
  and also lists devices for the common Linux drivers.
- For your Brother scanner, use the displayed profile name exactly with:
    NAPS2_PROFILE_NAME="your profile name"
EOF
