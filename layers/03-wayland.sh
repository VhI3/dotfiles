#!/bin/bash
set -euo pipefail

echo "==> [03] Wayland / Sway stack"

# Sway — tiling Wayland compositor (i3-compatible)
sudo apt install -y sway

# kanshi — automatic display profile management (Wayland replacement for xrandr scripts)
# Reads ~/.config/kanshi/config and applies the matching profile on output connect/disconnect
sudo apt install -y kanshi

# swaybg — sets the wallpaper on Wayland outputs
sudo apt install -y swaybg

# swaylock — screen locker for Sway ($mod+Shift+x)
sudo apt install -y swaylock

# swayidle — runs commands on idle (e.g. lock screen after timeout)
sudo apt install -y swayidle

# Waybar — status bar (replaces polybar; configured in dotfiles/config/waybar/)
sudo apt install -y waybar

# Kitty — GPU-accelerated terminal, set as $term in sway config
sudo apt install -y kitty

# Rofi — app launcher and power menu ($mod+d, $mod+Shift+e in sway config)
# rofi-wayland is the native Wayland port; same config as X11 rofi
sudo apt install -y rofi

# Mako — notification daemon for Wayland (replaces dunst)
# Dracula theme configured in dotfiles/config/mako/
sudo apt install -y mako-notifier

# Grim — screenshot tool for Wayland (bound to Print key in sway config)
sudo apt install -y grim

# Slurp — region selection for screenshots (used together with grim)
sudo apt install -y slurp

# Brightnessctl — screen brightness control (bound to Fn keys in sway config)
sudo apt install -y brightnessctl

# wl-clipboard — Wayland clipboard (wl-copy/wl-paste), used by Neovim and shell
sudo apt install -y wl-clipboard

# XWayland — runs X11 apps inside Wayland (MATLAB, some JetBrains tools, etc.)
sudo apt install -y xwayland

# dbus-user-session — required for Wayland session, portals, and notification daemon
sudo apt install -y dbus-user-session

# nm-applet — network manager tray icon (exec'd in sway config)
sudo apt install -y network-manager-gnome

# pactl — PulseAudio/PipeWire CLI, used by sway volume keybindings
sudo apt install -y pulseaudio-utils

# libnotify-bin — provides notify-send, used by mako and scripts (toggle_audio, alert alias)
sudo apt install -y libnotify-bin

# playerctl — media player control (play/pause/next from waybar)
sudo apt install -y playerctl

# XDG desktop portals — enable screen sharing and file pickers in Wayland apps
sudo apt install -y xdg-desktop-portal xdg-desktop-portal-wlr xdg-desktop-portal-gtk

echo "==> [03] rofi-power-menu"
# Script used by $mod+Shift+e in sway config for the power menu
mkdir -p "$HOME/.local/bin"
if [ ! -f "$HOME/.local/bin/rofi-power-menu" ]; then
    curl -fLo "$HOME/.local/bin/rofi-power-menu" \
        https://raw.githubusercontent.com/jluttine/rofi-power-menu/master/rofi-power-menu
    chmod +x "$HOME/.local/bin/rofi-power-menu"
fi

echo "==> [03] Done."
