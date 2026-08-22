#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$DOTFILES_DIR/config/dotfiles"
LOCAL_DOTFILES_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles"
PAPERLESS_DIR="$DOTFILES_DIR/projects/paperless-tools"

copy_if_missing() {
    local src="$1"
    local dst="$2"

    mkdir -p "$(dirname "$dst")"
    if [ -e "$dst" ]; then
        echo "==> Keeping existing $(basename "$dst")"
    else
        cp "$src" "$dst"
        echo "==> Created $(basename "$dst") from template"
    fi
}

copy_if_missing "$CONFIG_DIR/document-drives.env.example" "$LOCAL_DOTFILES_DIR/document-drives.env"
copy_if_missing "$CONFIG_DIR/document-shares.env.example" "$LOCAL_DOTFILES_DIR/document-shares.env"
copy_if_missing "$CONFIG_DIR/kulturzeit-downloader.env.example" "$LOCAL_DOTFILES_DIR/kulturzeit-downloader.env"
copy_if_missing "$CONFIG_DIR/media-shares.env.example" "$LOCAL_DOTFILES_DIR/media-shares.env"
copy_if_missing "$CONFIG_DIR/restic-backup.conf.example" "$HOME/.config/restic-backup.conf"
copy_if_missing "$PAPERLESS_DIR/paperless-tools.local.conf.example" "$LOCAL_DOTFILES_DIR/paperless-tools.local.conf"

mkdir -p "$HOME/.config/restic"
if [ ! -f "$HOME/.config/restic/password" ]; then
    printf '%s\n' 'change-this-password' > "$HOME/.config/restic/password"
    chmod 600 "$HOME/.config/restic/password"
    echo "==> Created ~/.config/restic/password placeholder"
fi

cat <<'EOF'

Next steps:
  1. Edit:
     - ~/.config/dotfiles/document-drives.env
     - ~/.config/dotfiles/document-shares.env
     - ~/.config/dotfiles/kulturzeit-downloader.env
     - ~/.config/dotfiles/media-shares.env
     - ~/.config/restic-backup.conf
     - ~/.config/dotfiles/paperless-tools.local.conf
  2. Replace the placeholder restic password in ~/.config/restic/password
  3. Re-run dots/link.sh after changing machine-specific settings
EOF
