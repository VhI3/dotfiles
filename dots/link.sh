#!/bin/bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"

symlink() {
    local src="$1"
    local dst="$2"
    mkdir -p "$(dirname "$dst")"
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        echo "    Backing up existing $dst → ${dst}.bak"
        mv "$dst" "${dst}.bak"
    fi
    ln -sfn "$src" "$dst"
    echo "    $dst → $src"
}

echo "==> Linking configs"

# Shell
symlink "$DOTFILES/bash/bashrc"       "$HOME/.bashrc"
symlink "$DOTFILES/bash/bash_aliases" "$HOME/.bash_aliases"

# Editors
symlink "$DOTFILES/config/nvim"       "$HOME/.config/nvim"
symlink "$DOTFILES/vim/vimrc"         "$HOME/.vimrc"

# CLI tools
symlink "$DOTFILES/ranger"            "$HOME/.config/ranger"

# Wayland / Sway stack
symlink "$DOTFILES/config/sway"       "$HOME/.config/sway"
symlink "$DOTFILES/config/waybar"     "$HOME/.config/waybar"
symlink "$DOTFILES/config/mako"       "$HOME/.config/mako"
symlink "$DOTFILES/config/kanshi"     "$HOME/.config/kanshi"
symlink "$DOTFILES/config/kitty"      "$HOME/.config/kitty"

# App launcher
symlink "$DOTFILES/config/rofi"       "$HOME/.config/rofi"

# Apps
symlink "$DOTFILES/config/lazygit"    "$HOME/.config/lazygit"
symlink "$DOTFILES/config/mutt"       "$HOME/.config/mutt"

echo "==> Done."
