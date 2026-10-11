#!/usr/bin/env bash
set -euo pipefail

pin_file="/etc/apt/preferences.d/99-griffo-ghostty-only"
old_pin_file="/etc/apt/preferences.d/99-neovim-appimage"

echo "==> Restricting Griffo APT repo to Ghostty only"
sudo rm -f "$old_pin_file"
sudo tee "$pin_file" >/dev/null <<'EOF'
# Keep the Griffo repository available for Ghostty, but do not let it replace
# normal Debian packages such as fzf or Neovim. Griffo currently exposes package
# metadata for multiple tools while some .deb downloads return 401 Unauthorized.
Package: ghostty
Pin: origin debian.griffo.io
Pin-Priority: 990

Package: *
Pin: origin debian.griffo.io
Pin-Priority: -1
EOF

echo "==> Installed APT pin: $pin_file"
echo "==> Current APT policy:"
apt-cache policy ghostty fzf neovim neovim-runtime | sed -n '1,140p'

echo
echo "Neovim should stay managed by:"
echo "  update-nvim"
echo
echo "After this, run:"
echo "  sudo nala update"
echo "  sudo nala upgrade"
