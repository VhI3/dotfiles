#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> [07] GRUB theme"
# Custom GRUB boot theme stored in dotfiles/14-grub/grub-master.zip
# Installs to /boot/grub/themes/ and updates /etc/default/grub

THEME_ZIP="$DOTFILES_DIR/14-grub/grub-master.zip"
THEME_DIR="/boot/grub/themes/grub-master"

if [ ! -f "$THEME_ZIP" ]; then
    echo "    ERROR: $THEME_ZIP not found, skipping."
    exit 1
fi

# Extract theme to /boot/grub/themes/
sudo mkdir -p /boot/grub/themes
sudo unzip -o "$THEME_ZIP" -d /boot/grub/themes/

# Set the theme in /etc/default/grub
if grep -q "^GRUB_THEME=" /etc/default/grub; then
    sudo sed -i "s|^GRUB_THEME=.*|GRUB_THEME=\"$THEME_DIR/theme.txt\"|" /etc/default/grub
else
    echo "GRUB_THEME=\"$THEME_DIR/theme.txt\"" | sudo tee -a /etc/default/grub
fi

# Apply changes
sudo update-grub

echo "==> [07] Done."
