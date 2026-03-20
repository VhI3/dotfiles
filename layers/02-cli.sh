#!/bin/bash
set -euo pipefail

echo "==> [02] CLI tools"
sudo apt install -y \
    fzf \
    ranger \
    ripgrep \
    fd-find \
    bat \
    wl-clipboard \
    xdg-utils

# Debian renames fd and bat binaries — symlink to canonical names
mkdir -p "$HOME/.local/bin"
[ ! -e "$HOME/.local/bin/fd" ]  && ln -s /usr/bin/fdfind "$HOME/.local/bin/fd"
[ ! -e "$HOME/.local/bin/bat" ] && ln -s /usr/bin/batcat "$HOME/.local/bin/bat"

echo "==> [02] eza"
sudo apt install -y eza 2>/dev/null || {
    # Fallback: install via cargo if not in apt (older Debian)
    . "$HOME/.cargo/env"
    cargo install eza
    cp "$HOME/.cargo/bin/eza" "$HOME/.local/bin/eza"
}

echo "==> [02] Neovim AppImage"
NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage"
mkdir -p "$HOME/.local/bin"
curl -fLo "$HOME/.local/bin/nvim" "$NVIM_URL"
chmod +x "$HOME/.local/bin/nvim"

echo "==> [02] lazygit"
LAZYGIT_VERSION=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
    | grep '"tag_name"' | cut -d'"' -f4 | sed 's/v//')
curl -fLo /tmp/lazygit.tar.gz \
    "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar -xf /tmp/lazygit.tar.gz -C /tmp lazygit
install /tmp/lazygit "$HOME/.local/bin/lazygit"
rm /tmp/lazygit.tar.gz /tmp/lazygit

echo "==> [02] Done."
