#!/bin/bash
set -euo pipefail

echo "==> [02] CLI tools"

# Fuzzy finder — used in shell (Ctrl+R history, Ctrl+T file search) and Neovim (Telescope)
sudo apt install -y fzf

# Terminal file manager with vim keybindings
sudo apt install -y ranger

# Fast grep replacement — used by Neovim live grep (Telescope)
sudo apt install -y ripgrep

# Fast find replacement — used by Neovim file finder (Telescope)
# Debian ships it as 'fdfind'; symlinked to 'fd' below
sudo apt install -y fd-find

# Better cat with syntax highlighting — used as pager and in fzf previews
# Debian ships it as 'batcat'; symlinked to 'bat' below
sudo apt install -y bat

# Wayland clipboard — wl-copy / wl-paste, used by Neovim and shell
sudo apt install -y wl-clipboard

# XDG utilities — xdg-open, used to open files from terminal in the right app
sudo apt install -y xdg-utils

# Debian renames fd and bat — symlink to canonical names expected by tools/configs
mkdir -p "$HOME/.local/bin"
[ ! -e "$HOME/.local/bin/fd" ]  && ln -s /usr/bin/fdfind "$HOME/.local/bin/fd"
[ ! -e "$HOME/.local/bin/bat" ] && ln -s /usr/bin/batcat "$HOME/.local/bin/bat"

echo "==> [02] eza"
# Modern ls replacement (replaces colorls) — icons, git status, tree view
sudo apt install -y eza 2>/dev/null || {
    # Fallback: install via cargo if not in apt (older Debian)
    . "$HOME/.cargo/env"
    cargo install eza
    cp "$HOME/.cargo/bin/eza" "$HOME/.local/bin/eza"
}

echo "==> [02] Neovim AppImage"
# Always pulls the latest stable release; AppImage runs without system dependencies
NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage"
mkdir -p "$HOME/.local/bin"
curl -fLo "$HOME/.local/bin/nvim" "$NVIM_URL"
chmod +x "$HOME/.local/bin/nvim"

echo "==> [02] lazygit"
# Terminal UI for git — Dracula theme configured in dotfiles/lazygitUI/
LAZYGIT_VERSION=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
    | grep '"tag_name"' | cut -d'"' -f4 | sed 's/v//')
curl -fLo /tmp/lazygit.tar.gz \
    "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar -xf /tmp/lazygit.tar.gz -C /tmp lazygit
install /tmp/lazygit "$HOME/.local/bin/lazygit"
rm /tmp/lazygit.tar.gz /tmp/lazygit

echo "==> [02] Done."
