#!/bin/bash
# Run this as root on a fresh Debian server before anything else.
# Debian server does not include sudo by default.
# Usage: su - then bash 00-sudo.sh

if [ "$EUID" -ne 0 ]; then
    echo "Error: run this script as root (su -)."
    exit 1
fi

if ! command -v sudo &>/dev/null; then
    echo "==> Installing sudo..."
    apt update && apt install -y sudo
fi

read -rp "Username to add to sudoers: " username

if ! id "$username" &>/dev/null; then
    echo "Error: user '$username' does not exist."
    exit 1
fi

if groups "$username" | grep -qw "sudo"; then
    echo "==> '$username' is already in sudo group."
else
    usermod -aG sudo "$username"
    echo "==> '$username' added to sudo group."
fi

read -rp "Reboot now? (y/n): " choice
[[ "$choice" == "y" || "$choice" == "Y" ]] && reboot
