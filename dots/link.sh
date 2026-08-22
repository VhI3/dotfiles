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

symlink_prefer_local() {
    local base_src="$1"
    local local_src="$2"
    local dst="$3"

    if [ -f "$local_src" ]; then
        symlink "$local_src" "$dst"
    else
        symlink "$base_src" "$dst"
    fi
}

ensure_real_dir() {
    local dir="$1"
    if [ -L "$dir" ]; then
        rm "$dir"
    fi
    mkdir -p "$dir"
}

link_dir_entries() {
    local src_dir="$1"
    local dst_dir="$2"
    shift 2

    ensure_real_dir "$dst_dir"

    local entry
    for entry in "$@"; do
        symlink "$src_dir/$entry" "$dst_dir/$entry"
    done
}

echo "==> Linking home/ → ~/"
symlink "$DOTFILES/home/bashrc"       "$HOME/.bashrc"
symlink "$DOTFILES/home/bash_aliases" "$HOME/.bash_aliases"
symlink "$DOTFILES/home/bash_profile" "$HOME/.bash_profile"
symlink "$DOTFILES/home/profile"      "$HOME/.profile"
symlink "$DOTFILES/home/vimrc"        "$HOME/.vimrc"
symlink_prefer_local "$DOTFILES/config/mutt/muttrc" "$DOTFILES/config/mutt/muttrc.local" "$HOME/.muttrc"

echo "==> Linking config/ → ~/.config/"
symlink "$DOTFILES/config/nvim"       "$HOME/.config/nvim"
symlink "$DOTFILES/config/kanshi"     "$HOME/.config/kanshi"
symlink "$DOTFILES/config/gtk-4.0"    "$HOME/.config/gtk-4.0"
symlink "$DOTFILES/config/fastfetch"  "$HOME/.config/fastfetch"
symlink "$DOTFILES/config/ranger"     "$HOME/.config/ranger"
ensure_real_dir "$HOME/.config/fontconfig/conf.d"
symlink "$DOTFILES/config/fontconfig/conf.d/99-naps2-ignore-universalis-adf.conf" "$HOME/.config/fontconfig/conf.d/99-naps2-ignore-universalis-adf.conf"
ensure_real_dir "$HOME/.config/isync"
ensure_real_dir "$HOME/.config/msmtp"
ensure_real_dir "$HOME/.config/mutt"
ensure_real_dir "$HOME/.config/dotfiles"

link_dir_entries "$DOTFILES/config/kitty" "$HOME/.config/kitty" \
    kitty.conf themes
link_dir_entries "$DOTFILES/config/ghostty" "$HOME/.config/ghostty" \
    config themes
link_dir_entries "$DOTFILES/config/eza" "$HOME/.config/eza" \
    themes
link_dir_entries "$DOTFILES/config/fzf" "$HOME/.config/fzf" \
    themes
link_dir_entries "$DOTFILES/config/lazygit" "$HOME/.config/lazygit" \
    config.yml themes
link_dir_entries "$DOTFILES/config/sway" "$HOME/.config/sway" \
    config hosts themes
link_dir_entries "$DOTFILES/config/swaylock" "$HOME/.config/swaylock" \
    themes
link_dir_entries "$DOTFILES/config/rofi" "$HOME/.config/rofi" \
    catppuccin-default.rasi config.rasi themes
link_dir_entries "$DOTFILES/config/zathura" "$HOME/.config/zathura" \
    catppuccin-frappe catppuccin-latte catppuccin-macchiato catppuccin-mocha zathurarc
link_dir_entries "$DOTFILES/config/waybar" "$HOME/.config/waybar" \
    config.jsonc style.css themes
link_dir_entries "$DOTFILES/config/swaync" "$HOME/.config/swaync" \
    config.json style.css themes

ensure_real_dir "$HOME/.config/systemd"
link_dir_entries "$DOTFILES/config/systemd/user" "$HOME/.config/systemd/user" \
    ollama.service \
    paperless-export-backup-fast.timer \
    paperless-export-backup.service \
    paperless-export-backup.timer \
    restic-documents-backup.service \
    restic-documents-backup.timer \
    ssd-hdd-live-sync.service \
    ssd-hdd-mirror-fast.timer \
    ssd-hdd-mirror.service \
    ssd-hdd-mirror.timer

symlink_prefer_local "$DOTFILES/config/isync/mbsyncrc" "$DOTFILES/config/isync/mbsyncrc.local" "$HOME/.config/isync/mbsyncrc"
symlink_prefer_local "$DOTFILES/config/msmtp/config" "$DOTFILES/config/msmtp/config.local" "$HOME/.config/msmtp/config"
symlink_prefer_local "$DOTFILES/config/mutt/muttrc" "$DOTFILES/config/mutt/muttrc.local" "$HOME/.config/mutt/muttrc"
symlink "$DOTFILES/config/mutt/mailcap" "$HOME/.config/mutt/mailcap"
symlink "$DOTFILES/config/mutt/themes" "$HOME/.config/mutt/themes"
symlink "$DOTFILES/config/applications/spotify.desktop" "$HOME/.local/share/applications/spotify.desktop"
symlink "$DOTFILES/config/applications/octave.desktop" "$HOME/.local/share/applications/octave.desktop"
symlink "$DOTFILES/config/applications/calibre.desktop" "$HOME/.local/share/applications/calibre.desktop"

# Clean up stale local desktop overrides that hide packaged launchers.
if [ -f "$HOME/.local/share/applications/qpdfview.desktop" ] && grep -q '^NoDisplay=true$' "$HOME/.local/share/applications/qpdfview.desktop"; then
    mkdir -p "$HOME/.local/share/applications/codex-backup"
    mv "$HOME/.local/share/applications/qpdfview.desktop" "$HOME/.local/share/applications/codex-backup/qpdfview.desktop"
    echo "    removed stale hidden qpdfview.desktop override"
fi

echo "==> Linking bin/ → ~/.local/bin/"
mkdir -p "$HOME/.local/bin"
symlink "$DOTFILES/bin/toggle_audio.sh"  "$HOME/.local/bin/toggle_audio"
symlink "$DOTFILES/bin/notify-volume.sh"     "$HOME/.local/bin/notify-volume"
symlink "$DOTFILES/bin/notify-brightness.sh" "$HOME/.local/bin/notify-brightness"
symlink "$DOTFILES/bin/notify-media.sh"      "$HOME/.local/bin/notify-media"
symlink "$DOTFILES/bin/notify-layout.sh"     "$HOME/.local/bin/notify-layout"
symlink "$DOTFILES/bin/notify-epos.sh"       "$HOME/.local/bin/notify-epos"
symlink "$DOTFILES/bin/show-keybindings.sh"  "$HOME/.local/bin/show-keybindings"
symlink "$DOTFILES/bin/focus-or-launch.sh"   "$HOME/.local/bin/focus-or-launch"
symlink "$DOTFILES/bin/matlab-sway.sh"       "$HOME/.local/bin/matlab-sway"
symlink "$DOTFILES/bin/octave-launch.sh"     "$HOME/.local/bin/octave-launch"
symlink "$DOTFILES/bin/blk.sh"               "$HOME/.local/bin/blk"
symlink "$DOTFILES/bin/normalize-filenames.sh" "$HOME/.local/bin/normalize-filenames"
symlink "$DOTFILES/bin/rename-document-tree-de.sh" "$HOME/.local/bin/rename-document-tree-de"
symlink "$DOTFILES/bin/clean-latex.sh"         "$HOME/.local/bin/clean-latex"
symlink "$DOTFILES/bin/safe-copy.sh"           "$HOME/.local/bin/safe-copy"
symlink "$DOTFILES/bin/mirror-drive.sh"        "$HOME/.local/bin/mirror-drive"
symlink "$DOTFILES/bin/run-ssd-hdd-mirror.sh"  "$HOME/.local/bin/run-ssd-hdd-mirror"
symlink "$DOTFILES/bin/watch-ssd-hdd-mirror.sh" "$HOME/.local/bin/watch-ssd-hdd-mirror"
symlink "$DOTFILES/bin/install-startup-document-mounts.sh" "$HOME/.local/bin/install-startup-document-mounts"
symlink "$DOTFILES/bin/enable-ssd-hdd-mirror.sh" "$HOME/.local/bin/enable-ssd-hdd-mirror"
symlink "$DOTFILES/bin/enable-ssd-hdd-mirror-fast.sh" "$HOME/.local/bin/enable-ssd-hdd-mirror-fast"
symlink "$DOTFILES/bin/enable-ssd-hdd-live-sync.sh" "$HOME/.local/bin/enable-ssd-hdd-live-sync"
symlink "$DOTFILES/bin/enable-restic-documents-backup.sh" "$HOME/.local/bin/enable-restic-documents-backup"
symlink "$DOTFILES/bin/enable-paperless-backup.sh" "$HOME/.local/bin/enable-paperless-backup"
symlink "$DOTFILES/bin/enable-paperless-backup-fast.sh" "$HOME/.local/bin/enable-paperless-backup-fast"
symlink "$DOTFILES/bin/restic-backup.sh"       "$HOME/.local/bin/restic-backup"
symlink "$DOTFILES/bin/restic-documents-backup-service.sh" "$HOME/.local/bin/restic-documents-backup-service"
symlink "$DOTFILES/bin/file-agent.py"          "$HOME/.local/bin/file-agent"
symlink "$DOTFILES/bin/sort-pdfs.sh"           "$HOME/.local/bin/sort-pdfs"
symlink "$DOTFILES/bin/sort-library.sh"        "$HOME/.local/bin/sort-library"
symlink "$DOTFILES/bin/rename-pdf-from-title.sh" "$HOME/.local/bin/rename-pdf-from-title"
symlink "$DOTFILES/bin/rofi-wifi.sh"         "$HOME/.local/bin/rofi-wifi"
symlink "$DOTFILES/bin/connect-keychron.sh"  "$HOME/.local/bin/connect-keychron"
symlink "$DOTFILES/bin/ghostty.sh"           "$HOME/.local/bin/ghostty"
symlink "$DOTFILES/bin/remove-software.sh"   "$HOME/.local/bin/remove-software"
symlink "$DOTFILES/bin/remove-ollama.sh"     "$HOME/.local/bin/remove-ollama"
symlink "$DOTFILES/bin/wallpaper.sh"    "$HOME/.local/bin/wallpaper"
symlink "$DOTFILES/bin/mount-sd.sh"     "$HOME/.local/bin/mount-sd"
symlink "$DOTFILES/bin/mount-smb-share.sh" "$HOME/.local/bin/mount-smb-share"
symlink "$DOTFILES/bin/mount-paperless-consume.sh" "$HOME/.local/bin/mount-paperless-consume"
symlink "$DOTFILES/bin/mount-ntfs.sh"   "$HOME/.local/bin/mount-ntfs"
symlink "$DOTFILES/bin/mount-media-shares.sh" "$HOME/.local/bin/mount-media-shares"
symlink "$DOTFILES/bin/mount-document-shares.sh" "$HOME/.local/bin/mount-document-shares"
symlink "$DOTFILES/bin/install-media-share-startup.sh" "$HOME/.local/bin/install-media-share-startup"
symlink "$DOTFILES/bin/bootstrap-home-server.sh" "$HOME/.local/bin/bootstrap-home-server"
symlink "$DOTFILES/bin/setup-epos.sh"   "$HOME/.local/bin/setup-epos"
symlink "$DOTFILES/bin/setup-claudecode.sh" "$HOME/.local/bin/setup-claudecode"
symlink "$DOTFILES/bin/setup-llama-vscode.sh" "$HOME/.local/bin/setup-llama-vscode"
symlink "$DOTFILES/bin/setup-ollama-home.sh" "$HOME/.local/bin/setup-ollama-home"
symlink "$DOTFILES/bin/enable-ollama-service.sh" "$HOME/.local/bin/enable-ollama-service"
symlink "$DOTFILES/bin/ollama-serve.sh" "$HOME/.local/bin/ollama-serve"
symlink "$DOTFILES/bin/setup-vscode-catppuccin.sh" "$HOME/.local/bin/setup-vscode-catppuccin"
symlink "$DOTFILES/bin/setup-paperless-tools.sh" "$HOME/.local/bin/setup-paperless-tools"
symlink "$DOTFILES/bin/setup-kulturzeit-downloader.sh" "$HOME/.local/bin/setup-kulturzeit-downloader"
symlink "$DOTFILES/bin/setup-local-configs.sh" "$HOME/.local/bin/setup-local-configs"
symlink "$DOTFILES/bin/post-install-check.sh" "$HOME/.local/bin/post-install-check"
symlink "$DOTFILES/bin/llama-vscode-cpu.sh" "$HOME/.local/bin/llama-vscode-cpu"
symlink "$DOTFILES/projects/paperless-tools/scan-to-paperless.sh" "$HOME/.local/bin/scan-to-paperless"
symlink "$DOTFILES/projects/paperless-tools/scan-glass-to-paperless.sh" "$HOME/.local/bin/scan-glass-to-paperless"
symlink "$DOTFILES/projects/paperless-tools/list-naps2-profiles.sh" "$HOME/.local/bin/list-naps2-profiles"
symlink "$DOTFILES/projects/paperless-tools/check-paperless.sh" "$HOME/.local/bin/check-paperless"
symlink "$DOTFILES/projects/paperless-tools/backup-paperless-to-pcloud.sh" "$HOME/.local/bin/backup-paperless-to-pcloud"
symlink "$DOTFILES/projects/paperless-tools/restore-paperless-from-export.sh" "$HOME/.local/bin/restore-paperless-from-export"
symlink "$DOTFILES/projects/paperless-tools/paperless-gui.sh" "$HOME/.local/bin/paperless-gui"
symlink "$DOTFILES/bin/sync-mail.sh"    "$HOME/.local/bin/sync-mail"
symlink "$DOTFILES/bin/kulturzeit-downloader.sh" "$HOME/.local/bin/kulturzeit-downloader"
symlink "$DOTFILES/bin/update-nvim.sh"  "$HOME/.local/bin/update-nvim"
symlink "$DOTFILES/bin/nvim-repair.sh" "$HOME/.local/bin/nvim-repair"
symlink "$DOTFILES/bin/repair-nvim-lazy-cache.sh" "$HOME/.local/bin/repair-nvim-lazy-cache"
symlink "$DOTFILES/bin/repair-nvim-lspconfig-cache.sh" "$HOME/.local/bin/repair-nvim-lspconfig-cache"
symlink "$DOTFILES/bin/update-github-desktop.sh" "$HOME/.local/bin/update-github-desktop"
symlink "$DOTFILES/bin/changeTheme.sh"  "$HOME/.local/bin/changeTheme"
symlink "$DOTFILES/bin/changeTheme.sh"  "$HOME/.local/bin/changeTheme.sh"
symlink "$DOTFILES/bin/kitty-theme.sh"   "$HOME/.local/bin/kitty-theme"
symlink "$DOTFILES/bin/nextcloud.sh"    "$HOME/.local/bin/nextcloud"
symlink "$DOTFILES/bin/select-sway-host.sh" "$HOME/.local/bin/select-sway-host"

"$DOTFILES/bin/changeTheme.sh" --init mocha
"$DOTFILES/bin/select-sway-host.sh"

if command -v systemctl >/dev/null 2>&1; then
    if systemctl --user daemon-reload >/dev/null 2>&1; then
        if [ -f "$HOME/.config/dotfiles/document-drives.env" ] && "$DOTFILES/bin/enable-ssd-hdd-mirror.sh" >/dev/null 2>&1; then
            echo "==> Enabled SSD/HDD mirror timer"
        else
            echo "==> Skipped SSD/HDD mirror timer auto-enable; configure local drive settings first if needed"
        fi
    else
        echo "==> User systemd not available yet; skip SSD/HDD mirror timer enable"
    fi
fi

echo "==> Done."
