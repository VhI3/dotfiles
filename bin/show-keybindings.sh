#!/usr/bin/env bash
set -euo pipefail

ROFI_THEME="${XDG_CONFIG_HOME:-$HOME/.config}/rofi/config.rasi"

cat <<'EOF' | rofi -dmenu -i -no-custom -p "Sway Keys" -theme "$ROFI_THEME" \
    -theme-str 'window { width: 52%; } listview { lines: 24; }'
Apps
Mod+Return    Kitty
Mod+d         Rofi app launcher
Mod+w         Firefox
Mod+e         Nautilus
Mod+c         VS Code
Mod+t         Telegram
Mod+m         Thunderbird
Mod+g         GitHub Desktop
Mod+p         Spotify
Mod+z         Zathura
Mod+x         Xournal++
Mod+y         MATLAB

System
Mod+Shift+r   Reload Sway
Mod+Shift+e   Power menu
Mod+Shift+t   Theme picker
Mod+Shift+n   Notification center
Mod+/         Show this shortcut list

Windows
Mod+Shift+q   Kill focused window
Mod+h/j/k/l   Focus left/down/up/right
Mod+Shift+h/j/k/l  Move window left/down/up/right
Mod+Ctrl+s    Layout stacking
Mod+Ctrl+w    Layout tabbed
Mod+Ctrl+e    Layout split toggle

Workspaces
Mod+1..0      Switch workspaces 1 to 10
Mod+Shift+1..0  Move window to workspaces 1 to 10
Mod+F1..F12   Switch workspaces 11 to 22
Mod+Shift+F1..F12  Move window to workspaces 11 to 22

Media
AudioPlay     Play/Pause with notification
AudioNext     Next track with notification
AudioPrev     Previous track with notification
AudioRaise    Volume up
AudioLower    Volume down
AudioMute     Toggle mute

Layout
Alt+Shift     Toggle keyboard layout
EOF
