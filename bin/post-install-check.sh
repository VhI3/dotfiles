#!/usr/bin/env bash
set -euo pipefail

SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
REPO_DIR="$(cd "$(dirname "$SCRIPT_PATH")/.." && pwd)"

pass_count=0
warn_count=0
fail_count=0

pass() {
    printf '[PASS] %s\n' "$1"
    pass_count=$((pass_count + 1))
}

warn() {
    printf '[WARN] %s\n' "$1"
    warn_count=$((warn_count + 1))
}

fail() {
    printf '[FAIL] %s\n' "$1"
    fail_count=$((fail_count + 1))
}

check_cmd() {
    local cmd="$1"
    if command -v "$cmd" >/dev/null 2>&1; then
        pass "command available: $cmd"
    else
        fail "missing command: $cmd"
    fi
}

check_file() {
    local path="$1"
    if [ -e "$path" ]; then
        pass "exists: $path"
    else
        fail "missing file: $path"
    fi
}

check_symlink() {
    local path="$1"
    if [ -L "$path" ]; then
        pass "symlink present: $path"
    else
        fail "expected symlink missing: $path"
    fi
}

check_optional_cmd() {
    local cmd="$1"
    if command -v "$cmd" >/dev/null 2>&1; then
        pass "optional command available: $cmd"
    else
        warn "optional command missing: $cmd"
    fi
}

check_non_placeholder() {
    local path="$1"
    local pattern="$2"
    if [ ! -f "$path" ]; then
        fail "missing file: $path"
        return
    fi

    if grep -Eq "$pattern" "$path"; then
        warn "placeholder or unresolved value still present in: $path"
    else
        pass "local values look customized: $path"
    fi
}

check_systemd_unit() {
    local unit="$1"
    if systemctl --user list-unit-files "$unit" >/dev/null 2>&1; then
        pass "user unit known: $unit"
    else
        warn "user unit not visible yet: $unit"
    fi
}

echo "==> Post-install portability check"
echo

echo "==> Core commands"
check_cmd git
check_cmd curl
check_cmd wget
check_cmd sudo
check_cmd bash
check_cmd systemctl
check_cmd nvim
check_cmd sway
check_cmd ghostty
check_cmd rofi
check_cmd playerctl
check_cmd restic
check_optional_cmd codium
check_optional_cmd thunderbird
check_optional_cmd spotify
check_optional_cmd signal-desktop
echo

echo "==> Linked shell and config files"
check_symlink "$HOME/.bashrc"
check_symlink "$HOME/.bash_aliases"
check_symlink "$HOME/.bash_profile"
check_symlink "$HOME/.profile"
check_symlink "$HOME/.config/sway"
check_symlink "$HOME/.config/waybar"
check_symlink "$HOME/.config/ghostty"
check_symlink "$HOME/.config/nvim"
echo

echo "==> Linked helper commands"
check_symlink "$HOME/.local/bin/changeTheme"
check_symlink "$HOME/.local/bin/show-keybindings"
check_symlink "$HOME/.local/bin/setup-local-configs"
check_symlink "$HOME/.local/bin/post-install-check"
check_symlink "$HOME/.local/bin/bootstrap-home-server"
check_symlink "$HOME/.local/bin/nvim-repair"
check_symlink "$HOME/.local/bin/repair-nvim-lazy-cache"
check_symlink "$HOME/.local/bin/repair-nvim-lspconfig-cache"
check_symlink "$HOME/.local/bin/setup-paperless-tools"
check_symlink "$HOME/.local/bin/setup-kulturzeit-downloader"
check_symlink "$HOME/.local/bin/backup-paperless-to-pcloud"
check_symlink "$HOME/.local/bin/restore-paperless-from-export"
check_symlink "$HOME/.local/bin/mount-paperless-consume"
check_symlink "$HOME/.local/bin/mount-document-shares"
echo

echo "==> Local machine config files"
check_file "$HOME/.config/dotfiles/document-drives.env"
check_file "$HOME/.config/dotfiles/document-shares.env"
check_file "$HOME/.config/dotfiles/kulturzeit-downloader.env"
check_file "$HOME/.config/dotfiles/media-shares.env"
check_file "$HOME/.config/dotfiles/paperless-tools.local.conf"
check_file "$HOME/.config/restic-backup.conf"
check_file "$HOME/.config/restic/password"
check_non_placeholder "$HOME/.config/dotfiles/document-drives.env" 'replace-with-uuid|your-user'
check_non_placeholder "$HOME/.config/restic/password" '^change-this-password$'
echo

echo "==> User systemd units"
check_systemd_unit "ssd-hdd-mirror.service"
check_systemd_unit "ssd-hdd-mirror.timer"
check_systemd_unit "restic-documents-backup.service"
check_systemd_unit "restic-documents-backup.timer"
check_systemd_unit "paperless-export-backup.service"
check_systemd_unit "paperless-export-backup.timer"
check_systemd_unit "ollama.service"
echo

echo "==> Paperless helpers"
check_cmd scan-to-paperless
check_cmd list-naps2-profiles
check_cmd check-paperless
check_cmd backup-paperless-to-pcloud
check_cmd restore-paperless-from-export
check_cmd mount-paperless-consume
check_cmd mount-document-shares
check_cmd kulturzeit-downloader
echo

echo "==> Restore docs"
check_file "$REPO_DIR/README.md"
check_file "$REPO_DIR/CHEATSHEET.md"
check_file "$REPO_DIR/PORTABILITY.md"
check_file "$REPO_DIR/docs/HOME-SERVER-SERVER-BOOTSTRAP.md"
echo

echo "==> Summary"
printf 'PASS: %d\n' "$pass_count"
printf 'WARN: %d\n' "$warn_count"
printf 'FAIL: %d\n' "$fail_count"

if [ "$fail_count" -gt 0 ]; then
    exit 1
fi
