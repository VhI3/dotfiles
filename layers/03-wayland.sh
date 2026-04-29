#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/lib-package-manager.sh"

echo "==> [03] Wayland / Sway stack"

echo "==> [03] Ghostty Debian repository"
sudo mkdir -p /usr/share/keyrings
if [ ! -f /usr/share/keyrings/debian.griffo.io.gpg ]; then
    curl -fsSL https://debian.griffo.io/EA0F721D231FDD3A0A17B9AC7808B4DD62C41256.asc |
        sudo gpg --dearmor -o /usr/share/keyrings/debian.griffo.io.gpg
fi

ghostty_list_file="/etc/apt/sources.list.d/debian.griffo.io.list"
ghostty_repo_line="deb [signed-by=/usr/share/keyrings/debian.griffo.io.gpg] https://debian.griffo.io/apt $(lsb_release -sc) main"
if [ ! -f "$ghostty_list_file" ] || ! grep -Fxq "$ghostty_repo_line" "$ghostty_list_file"; then
    printf '%s\n' "$ghostty_repo_line" | sudo tee "$ghostty_list_file" >/dev/null
fi

pm_update

# Sway — tiling Wayland compositor (i3-compatible)
pm_install sway

# kanshi — automatic display profile management (Wayland replacement for xrandr scripts)
# Reads ~/.config/kanshi/config and applies the matching profile on output connect/disconnect
pm_install kanshi

# swaybg — sets the wallpaper on Wayland outputs
pm_install swaybg

# swaylock — screen locker for Sway ($mod+Shift+x)
pm_install swaylock

# swayidle — runs commands on idle (e.g. lock screen after timeout)
pm_install swayidle

# Waybar — status bar (replaces polybar; configured in dotfiles/config/waybar/)
pm_install waybar

# Ghostty — default terminal in Sway
pm_install ghostty

# Kitty — secondary GPU-accelerated terminal, kept alongside Ghostty
pm_install kitty

# Rofi — app launcher and power menu ($mod+d, $mod+Shift+e in sway config)
# rofi-wayland is the native Wayland port; same config as X11 rofi
pm_install rofi

# Sway Notification Center — notification daemon + control center for wlroots
pm_install sway-notification-center
systemctl --user disable --now dunst.service 2>/dev/null || true
systemctl --user mask dunst.service 2>/dev/null || true
systemctl --user enable swaync.service 2>/dev/null || true

# Grim — screenshot tool for Wayland (bound to Print key in sway config)
pm_install grim

# Slurp — region selection for screenshots (used together with grim)
pm_install slurp

# Brightnessctl — screen brightness control (bound to Fn keys in sway config)
pm_install brightnessctl

# wl-clipboard — Wayland clipboard (wl-copy/wl-paste), used by Neovim and shell
pm_install wl-clipboard

# XWayland — runs X11 apps inside Wayland (MATLAB, some JetBrains tools, etc.)
pm_install xwayland

# dbus-user-session — required for Wayland session, portals, and notification daemon
pm_install dbus-user-session

# nm-applet — network manager tray icon (exec'd in sway config)
pm_install network-manager-gnome

# pactl — PulseAudio/PipeWire CLI, used by sway volume keybindings
pm_install pulseaudio-utils

# libnotify-bin — provides notify-send, used by swaync and helper scripts
pm_install libnotify-bin

# playerctl — media player control (play/pause/next from waybar)
pm_install playerctl

# XDG desktop portals — enable screen sharing and file pickers in Wayland apps
pm_install xdg-desktop-portal xdg-desktop-portal-wlr xdg-desktop-portal-gtk

echo "==> [03] rofi-power-menu"
# Script used by $mod+Shift+e in sway config for the power menu
mkdir -p "$HOME/.local/bin"
if [ ! -f "$HOME/.local/bin/rofi-power-menu" ]; then
    curl -fLo "$HOME/.local/bin/rofi-power-menu" \
        https://raw.githubusercontent.com/jluttine/rofi-power-menu/master/rofi-power-menu
    chmod +x "$HOME/.local/bin/rofi-power-menu"
fi

echo "==> [03] Done."
