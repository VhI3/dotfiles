#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOOLS_DIR="$DOTFILES_DIR/projects/paperless-tools"
EXAMPLE_FILE="$TOOLS_DIR/paperless-tools.local.conf.example"
LOCAL_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/paperless-tools.local.conf"

if [ ! -f "$EXAMPLE_FILE" ]; then
    echo "setup-paperless-tools: example file not found: $EXAMPLE_FILE" >&2
    exit 1
fi

mkdir -p "$(dirname "$LOCAL_FILE")"

if [ -f "$LOCAL_FILE" ]; then
    echo "==> Paperless local config already exists"
    echo "File: $LOCAL_FILE"
else
    cp "$EXAMPLE_FILE" "$LOCAL_FILE"
    echo "==> Created Paperless local config"
    echo "File: $LOCAL_FILE"
fi

cat <<EOF

Next steps:
  1. Edit the local override file if this machine needs different paths:
     $LOCAL_FILE
  2. Check the Paperless stack:
     cd $TOOLS_DIR && ./check-paperless.sh
  3. Test a backup run:
     cd $TOOLS_DIR && ./backup-paperless-to-pcloud.sh

Portable defaults already come from:
  $TOOLS_DIR/paperless-tools.conf
EOF
