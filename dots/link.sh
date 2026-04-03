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

echo "==> Linking home/ → ~/"
symlink "$DOTFILES/home/bashrc"       "$HOME/.bashrc"
symlink "$DOTFILES/home/bash_aliases" "$HOME/.bash_aliases"
symlink "$DOTFILES/home/vimrc"        "$HOME/.vimrc"
symlink "$DOTFILES/config/mutt/muttrc" "$HOME/.muttrc"

echo "==> Linking config/ → ~/.config/"
symlink "$DOTFILES/config/nvim"       "$HOME/.config/nvim"
symlink "$DOTFILES/config/sway"       "$HOME/.config/sway"
symlink "$DOTFILES/config/waybar"     "$HOME/.config/waybar"
symlink "$DOTFILES/config/kanshi"     "$HOME/.config/kanshi"
symlink "$DOTFILES/config/kitty"      "$HOME/.config/kitty"
symlink "$DOTFILES/config/ghostty"    "$HOME/.config/ghostty"
symlink "$DOTFILES/config/fastfetch"  "$HOME/.config/fastfetch"
symlink "$DOTFILES/config/rofi"       "$HOME/.config/rofi"
symlink "$DOTFILES/config/swaync"     "$HOME/.config/swaync"
symlink "$DOTFILES/config/eza"        "$HOME/.config/eza"
symlink "$DOTFILES/config/isync"      "$HOME/.config/isync"
symlink "$DOTFILES/config/msmtp"      "$HOME/.config/msmtp"
symlink "$DOTFILES/config/ranger"     "$HOME/.config/ranger"
symlink "$DOTFILES/config/zathura"    "$HOME/.config/zathura"
symlink "$DOTFILES/config/swaylock"   "$HOME/.config/swaylock"
symlink "$DOTFILES/config/lazygit"    "$HOME/.config/lazygit"
symlink "$DOTFILES/config/mutt"       "$HOME/.config/mutt"
symlink "$DOTFILES/config/applications/spotify.desktop" "$HOME/.local/share/applications/spotify.desktop"

echo "==> Linking bin/ → ~/.local/bin/"
mkdir -p "$HOME/.local/bin"
symlink "$DOTFILES/bin/toggle_audio.sh"  "$HOME/.local/bin/toggle_audio"
symlink "$DOTFILES/bin/notify-volume.sh"     "$HOME/.local/bin/notify-volume"
symlink "$DOTFILES/bin/notify-brightness.sh" "$HOME/.local/bin/notify-brightness"
symlink "$DOTFILES/bin/notify-media.sh"      "$HOME/.local/bin/notify-media"
symlink "$DOTFILES/bin/notify-layout.sh"     "$HOME/.local/bin/notify-layout"
symlink "$DOTFILES/bin/focus-or-launch.sh"   "$HOME/.local/bin/focus-or-launch"
symlink "$DOTFILES/bin/wallpaper.sh"    "$HOME/.local/bin/wallpaper"
symlink "$DOTFILES/bin/mount-sd.sh"     "$HOME/.local/bin/mount-sd"
symlink "$DOTFILES/bin/setup-epos.sh"   "$HOME/.local/bin/setup-epos"
symlink "$DOTFILES/bin/sync-mail.sh"    "$HOME/.local/bin/sync-mail"
symlink "$DOTFILES/bin/update-nvim.sh"  "$HOME/.local/bin/update-nvim"
symlink "$DOTFILES/bin/changeTheme.sh"  "$HOME/.local/bin/changeTheme"
symlink "$DOTFILES/bin/changeTheme.sh"  "$HOME/.local/bin/changeTheme.sh"
symlink "$DOTFILES/bin/kitty-theme.sh"   "$HOME/.local/bin/kitty-theme"
symlink "$DOTFILES/bin/nextcloud.sh"    "$HOME/.local/bin/nextcloud"
symlink "$DOTFILES/bin/select-sway-host.sh" "$HOME/.local/bin/select-sway-host"

"$DOTFILES/bin/changeTheme.sh" --init mocha
"$DOTFILES/bin/select-sway-host.sh"

echo "==> Done."
