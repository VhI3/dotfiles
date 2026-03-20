#!/bin/bash
set -euo pipefail

echo "==> [03] Wayland / Sway stack"
sudo apt install -y \
    sway \
    swaybg \
    swaylock \
    swayidle \
    waybar \
    kitty \
    rofi \
    mako-notifier \
    grim \
    slurp \
    brightnessctl \
    wl-clipboard \
    xwayland \
    dbus-user-session \
    network-manager-gnome \
    pulseaudio-utils \
    playerctl

echo "==> [03] rofi-power-menu"
# Script used in sway config for the power menu
mkdir -p "$HOME/.local/bin"
if [ ! -f "$HOME/.local/bin/rofi-power-menu" ]; then
    curl -fLo "$HOME/.local/bin/rofi-power-menu" \
        https://raw.githubusercontent.com/jluttine/rofi-power-menu/master/rofi-power-menu
    chmod +x "$HOME/.local/bin/rofi-power-menu"
fi

echo "==> [03] Done."
