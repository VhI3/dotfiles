#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> [07] GRUB theme"
# Catppuccin GRUB theme
# Upstream: https://github.com/catppuccin/grub
# Usage:
#   GRUB_THEME_FLAVOUR=macchiato ./layers/07-grub.sh

THEME_FLAVOUR="${GRUB_THEME_FLAVOUR:-mocha}"
case "$THEME_FLAVOUR" in
    latte|frappe|macchiato|mocha) ;;
    *)
        echo "    ERROR: invalid GRUB_THEME_FLAVOUR '$THEME_FLAVOUR'" >&2
        echo "    Choose one of: latte, frappe, macchiato, mocha" >&2
        exit 1
        ;;
esac

TMP_DIR="$(mktemp -d)"
ARCHIVE_URL="https://github.com/catppuccin/grub/archive/refs/heads/main.tar.gz"
THEME_NAME="catppuccin-${THEME_FLAVOUR}-grub-theme"
THEME_SRC="$TMP_DIR/grub-main/src/$THEME_NAME"
THEME_DIR="/usr/share/grub/themes/$THEME_NAME"

cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

echo "    Downloading Catppuccin GRUB ($THEME_FLAVOUR)..."
curl -fsSL "$ARCHIVE_URL" | tar -xz -C "$TMP_DIR"

if [ ! -d "$THEME_SRC" ]; then
    echo "    ERROR: theme source not found: $THEME_SRC" >&2
    exit 1
fi

sudo mkdir -p /usr/share/grub/themes
sudo rm -rf "$THEME_DIR"
sudo cp -r "$THEME_SRC" "$THEME_DIR"

# Set the theme in /etc/default/grub
if grep -q '^GRUB_THEME=' /etc/default/grub; then
    sudo sed -i "s|^GRUB_THEME=.*|GRUB_THEME=\"$THEME_DIR/theme.txt\"|" /etc/default/grub
else
    echo "GRUB_THEME=\"$THEME_DIR/theme.txt\"" | sudo tee -a /etc/default/grub
fi

# GRUB themes will not be shown if the console terminal output is forced.
if grep -q '^GRUB_TERMINAL_OUTPUT="console"' /etc/default/grub; then
    sudo sed -i 's|^GRUB_TERMINAL_OUTPUT="console"|# GRUB_TERMINAL_OUTPUT="console"|' /etc/default/grub
fi

# Apply changes
sudo update-grub

echo "==> [07] Done."
