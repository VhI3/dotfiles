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

# Editor
symlink "$DOTFILES/nvim"              "$HOME/.config/nvim"
symlink "$DOTFILES/vim/vimrc"         "$HOME/.vimrc"

# CLI tools
symlink "$DOTFILES/ranger"            "$HOME/.config/ranger"
symlink "$DOTFILES/FZF"               "$HOME/.config/fzf"

# Wayland / Sway
symlink "$DOTFILES/config/sway"   "$HOME/.config/sway"
symlink "$DOTFILES/config/waybar" "$HOME/.config/waybar"
symlink "$DOTFILES/config/mako"   "$HOME/.config/mako"

# App launcher (rofi — works with rofi-wayland)
symlink "$DOTFILES/11-rofi"           "$HOME/.config/rofi"

# Lazygit theme
mkdir -p "$HOME/.config/lazygit"
symlink "$DOTFILES/lazygitUI/dracula.yml" "$HOME/.config/lazygit/config.yml"

echo "==> Done."
