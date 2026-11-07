#!/usr/bin/env bash
set -euo pipefail

pin_file="/etc/apt/preferences.d/99-griffo-ghostty-only"
old_pin_file="/etc/apt/preferences.d/99-neovim-appimage"

as_root() {
    if [ "${EUID:-$(id -u)}" -eq 0 ]; then
        "$@"
    else
        sudo "$@"
    fi
}

disable_file() {
    local file="$1" backup="${1}.disabled"
    [ -f "$file" ] || return 0
    if [ -e "$backup" ]; then
        backup="${file}.$(date +%Y%m%d-%H%M%S)-$$.disabled"
    fi
    as_root mv -- "$file" "$backup"
    printf 'Disabled %s (saved as %s)\n' "$file" "$backup"
}

# Keep this historical filename so an existing Ghostty allow-rule is replaced.
pin_content="$(cat <<'EOF'
# Griffo APT downloads require a subscription. Use GitHub releases for Ghostty
# (update-ghostty), the AppImage for Neovim, and Debian for other packages.
Package: *
Pin: origin debian.griffo.io
Pin-Priority: -1

Package: *
Pin: origin deb.griffo.io
Pin-Priority: -1
EOF
)"

if ! cmp -s "$pin_file" <(printf '%s\n' "$pin_content"); then
    as_root install -d -m 0755 /etc/apt/preferences.d
    printf '%s\n' "$pin_content" | as_root tee "$pin_file" >/dev/null
    printf 'Updated APT policy: %s\n' "$pin_file"
fi

disable_file "$old_pin_file"
for repo_file in \
    /etc/apt/sources.list.d/debian.griffo.io.list \
    /etc/apt/sources.list.d/debian.griffo.io.sources \
    /etc/apt/sources.list.d/deb.griffo.io.list \
    /etc/apt/sources.list.d/deb.griffo.io.sources; do
    if [ -f "$repo_file" ] && grep -Eq 'https?://(debian|deb)\.griffo\.io([/[:space:]]|$)' "$repo_file"; then
        disable_file "$repo_file"
    fi
done

echo "Griffo APT downloads disabled. Ghostty uses update-ghostty; Neovim uses update-nvim."
