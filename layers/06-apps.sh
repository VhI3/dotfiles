#!/bin/bash
set -euo pipefail

echo "==> [06] Zathura"
# Minimal PDF/document viewer with vim keybindings
# zathura-pdf-poppler adds PDF support (not included by default)
sudo apt install -y zathura zathura-pdf-poppler

echo "==> [06] LaTeX (texlive-full — ~4GB)"
# Full LaTeX distribution: includes pdflatex, xelatex, lualatex, beamer, tikz, etc.
# Use texlive-latex-extra instead if disk space is a concern (~800MB)
sudo apt install -y texlive-full

echo "==> [06] Spotify"
# Official Spotify apt repository — not in Debian repos by default
if ! command -v spotify &>/dev/null; then
    curl -sS https://download.spotify.com/debian/pubkey_6224F9941A8AA6D1.gpg \
        | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
    echo "deb http://repository.spotify.com stable non-free" \
        | sudo tee /etc/apt/sources.list.d/spotify.list
    sudo apt update && sudo apt install -y spotify-client
else
    echo "    Spotify already installed, skipping."
fi

echo "==> [06] GitHub Desktop"
# Official Linux build maintained by shiftkey (not in Debian repos)
# Assigned to workspace 17 in sway config
if ! command -v github-desktop &>/dev/null; then
    wget -qO /tmp/shiftkey.gpg https://apt.packages.shiftkey.dev/gpg.key
    gpg --dearmor < /tmp/shiftkey.gpg \
        | sudo tee /usr/share/keyrings/shiftkey-packages.gpg > /dev/null
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/shiftkey-packages.gpg] https://apt.packages.shiftkey.dev/ubuntu/ any main" \
        | sudo tee /etc/apt/sources.list.d/shiftkey-packages.list
    sudo apt update && sudo apt install -y github-desktop
    rm /tmp/shiftkey.gpg
else
    echo "    GitHub Desktop already installed, skipping."
fi

echo "==> [06] Done."
