#!/bin/bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
HOST_NAME="${1:-$(hostname -s)}"
HOST_SOURCE="$DOTFILES/config/sway/hosts/${HOST_NAME}.conf"
HOST_LOCAL="$DOTFILES/config/sway/host.local.conf"

if [ -f "$HOST_SOURCE" ]; then
    ln -sfn "hosts/${HOST_NAME}.conf" "$HOST_LOCAL"
    echo "==> Using sway host config: ${HOST_NAME}"
else
    : > "$HOST_LOCAL"
    echo "==> No sway host config for ${HOST_NAME}; using shared config only."
fi
