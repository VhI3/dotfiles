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

echo "==> [06] Firefox"
# Mozilla's official apt repo — installs stable Firefox, not Debian's ESR fork
# Pin-priority 1000 ensures Mozilla's version always wins over Debian's
if ! command -v firefox &>/dev/null; then
    wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- \
        | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
    echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" \
        | sudo tee /etc/apt/sources.list.d/mozilla.list > /dev/null
    echo 'Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000' | sudo tee /etc/apt/preferences.d/mozilla > /dev/null
    sudo apt update && sudo apt install -y firefox
    sudo apt remove --purge -y firefox-esr 2>/dev/null || true
else
    echo "    Firefox already installed, skipping."
fi

echo "==> [06] LibreWolf"
# Privacy-hardened Firefox fork — installed via extrepo (Debian's external repo manager)
if ! command -v librewolf &>/dev/null; then
    sudo apt install -y extrepo
    sudo extrepo enable librewolf
    sudo apt update && sudo apt install -y librewolf
else
    echo "    LibreWolf already installed, skipping."
fi

echo "==> [06] NeoMutt"
# Terminal email stack:
# - neomutt for the UI
# - isync (mbsync) syncs IMAP to local Maildir
# - msmtp sends mail via SMTP
# - urlscan opens URLs from mail nicely inside the terminal workflow
sudo apt install -y neomutt isync msmtp urlscan

echo "==> [06] Thunderbird"
# Downloaded directly from Mozilla (not Debian's outdated ESR package)
# Installs to ~/.opt/thunderbird, symlinked to ~/.local/bin/thunderbird
INSTALL_DIR="$HOME/.opt/thunderbird"
THUNDERBIRD_BIN="$INSTALL_DIR/thunderbird"
CURRENT_VERSION=$( [ -x "$THUNDERBIRD_BIN" ] && "$THUNDERBIRD_BIN" --version | awk '{print $2}' || echo "none" )
LATEST_VERSION=$(curl -sI "https://download.mozilla.org/?product=thunderbird-latest&os=linux64&lang=en-US" \
    | grep -i "location" | grep -oE "[0-9]+\.[0-9]+(\.[0-9]+)?")
if [ "$CURRENT_VERSION" != "$LATEST_VERSION" ]; then
    echo "    Installing Thunderbird $LATEST_VERSION"
    mkdir -p "$HOME/.opt"
    rm -rf "$INSTALL_DIR"
    wget -q -O /tmp/thunderbird.tar.bz2 \
        "https://download.mozilla.org/?product=thunderbird-latest&os=linux64&lang=en-US"
    tar -xjf /tmp/thunderbird.tar.bz2 -C "$HOME/.opt"
    rm /tmp/thunderbird.tar.bz2
    mkdir -p "$HOME/.local/bin" "$HOME/.local/share/applications"
    ln -sf "$THUNDERBIRD_BIN" "$HOME/.local/bin/thunderbird"
    cat > "$HOME/.local/share/applications/thunderbird.desktop" <<EOF
[Desktop Entry]
Name=Thunderbird
GenericName=Email Client
Exec=$HOME/.local/bin/thunderbird
Icon=$INSTALL_DIR/chrome/icons/default/default128.png
Terminal=false
Type=Application
Categories=Network;Email;
StartupWMClass=thunderbird
EOF
else
    echo "    Thunderbird $CURRENT_VERSION already up-to-date, skipping."
fi

echo "==> [06] VSCodium"
# VSCodium — telemetry-free VS Code build from official apt repo
if ! command -v codium &>/dev/null; then
    curl -fSsL https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
        | sudo gpg --dearmor | sudo tee /usr/share/keyrings/vscodium.gpg > /dev/null
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/vscodium.gpg] https://download.vscodium.com/debs vscodium main" \
        | sudo tee /etc/apt/sources.list.d/vscodium.list
    sudo apt update && sudo apt install -y codium
else
    echo "    VSCodium already installed, skipping."
fi

echo "==> [06] Done."
