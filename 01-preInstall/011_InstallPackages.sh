#!/bin/bash

## Step 1: Add Debian Testing Repositories
#if ! grep -q "testing" /etc/apt/sources.list; then
#    echo "Adding Debian Testing Repositories..."
#    sudo tee -a /etc/apt/sources.list >/dev/null <<EOL
#deb http://deb.debian.org/debian testing main contrib non-free
#deb-src http://deb.debian.org/debian testing main contrib non-free
#EOL
#    echo "Configuring package priorities..."
#    sudo tee /etc/apt/preferences.d/testing >/dev/null <<EOL
#Package: *
#Pin: release a=stable
#Pin-Priority: 700
#
#Package: *
#Pin: release a=testing
#Pin-Priority: 650
#EOL
#fi

## Step 2: Update and Upgrade System
echo "Updating and upgrading system..."
sudo apt update && apt upgrade -y && apt autoremove -y

# Step 3: Install Essential Packages
echo "Installing essential packages..."
sudo apt install build-essential \
  xserver-xorg-core xinit xserver-xorg-input-libinput x11-xserver-utils \
  i3 git wget curl python3 python3-venv python3-pip \
  ninja-build cmake xinput cargo xclip libfuse2 jq \
  x11-utils

# sudo apt install sway swaybg swayidle swaylock xwayland \
# waybar wl-clipboard grim slurp \
# xdg-desktop-portal xdg-desktop-portal-wlr
