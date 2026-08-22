#!/bin/bash
set -euo pipefail

APPIMAGE="${HOME}/.opt/nextcloud/Nextcloud-33.0.2-x86_64.AppImage"

if [ ! -x "$APPIMAGE" ]; then
    echo "Nextcloud AppImage not found or not executable: $APPIMAGE" >&2
    exit 1
fi

# The AppImage only ships the XCB Qt platform plugin, so force XWayland on Sway.
exec env QT_QPA_PLATFORM=xcb "$APPIMAGE" "$@"
