#!/bin/bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
LAYERS="$DOTFILES/layers"

run_layer() {
    bash "$LAYERS/$1"
}

echo "╔══════════════════════════════════╗"
echo "║       dotfiles installer         ║"
echo "╚══════════════════════════════════╝"
echo ""
echo "Layers:"
echo "  0) sudo     — add user to sudoers (run as root on fresh Debian install)"
echo "  1) base     — nala bootstrap, base packages, Python, nvm/Node, Rust"
echo "  2) cli      — Neovim AppImage, fzf, ranger, ripgrep, eza, lazygit, bat"
echo "  3) wayland  — sway, waybar, kitty, rofi, swaync, grim, swaylock, kanshi"
echo "  4) fonts    — JetBrainsMono & SpaceMono Nerd Fonts"
echo "  5) dev      — gcc, g++, cmake, ninja, clangd, gdb, rust-analyzer"
echo "  6) apps     — firefox, spotify, thunderbird, vscodium, neomutt, mbsync, msmtp"
echo "  7) grub     — Catppuccin GRUB bootloader theme"
echo "  8) octave   — GNU Octave with symbolic & statistics packages"
echo "  9) sddm     — SDDM display manager + Catppuccin login theme"
echo "  a) all      — run all layers in order"
echo "  l) link     — symlink configs only"
echo "  q) quit"
echo ""

while true; do
    read -rp "Select layer(s) [0-9/a/l/q]: " choice
    case "$choice" in
        0) bash "$LAYERS/00-sudo.sh" ;;
        1) run_layer 01-base.sh ;;
        2) run_layer 02-cli.sh ;;
        3) run_layer 03-wayland.sh ;;
        4) run_layer 04-fonts.sh ;;
        5) run_layer 05-dev.sh ;;
        6) run_layer 06-apps.sh ;;
        7) run_layer 07-grub.sh ;;
        8) run_layer 08-octave.sh ;;
        9) run_layer 09-sddm.sh ;;
        a)
            run_layer 01-base.sh
            run_layer 02-cli.sh
            run_layer 03-wayland.sh
            run_layer 04-fonts.sh
            run_layer 05-dev.sh
            run_layer 06-apps.sh
            run_layer 07-grub.sh
            run_layer 08-octave.sh
            run_layer 09-sddm.sh
            bash "$DOTFILES/dots/link.sh"
            ;;
        l) bash "$DOTFILES/dots/link.sh" ;;
        q) echo "Bye."; exit 0 ;;
        *) echo "Invalid choice." ;;
    esac
    echo ""
done
