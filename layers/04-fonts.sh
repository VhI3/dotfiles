#!/bin/bash
set -euo pipefail

echo "==> [04] Nerd Fonts"
FONTS_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONTS_DIR"

install_nerd_font() {
    local name="$1"
    local file="$2"
    if fc-list | grep -qi "$name"; then
        echo "    $name already installed, skipping."
        return
    fi
    echo "    Installing $name..."
    local url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${file}"
    curl -fLo "/tmp/${file}" "$url"
    unzip -o "/tmp/${file}" -d "$FONTS_DIR" '*.ttf' '*.otf' 2>/dev/null || true
    rm "/tmp/${file}"
}

install_nerd_font "JetBrainsMono"  "JetBrainsMono.zip"
install_nerd_font "SpaceMono"      "SpaceMono.zip"

fc-cache -f
echo "==> [04] Done."
