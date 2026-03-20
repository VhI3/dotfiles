#!/bin/bash

# Step 12: Install i3pystatus (Optional)
echo "Do you want to install i3pystatus? (y/n)"
read -n 1 i3pystatusInstall
echo

if [[ "$i3pystatusInstall" == "y" || "$i3pystatusInstall" == "Y" ]]; then
  echo "Installing i3pystatus..."

  # Create the directory for the virtual environment if it doesn't exist
  CONFIG_DIR="$HOME/.config/i3pystatus"
  VENV_DIR="$CONFIG_DIR/venv"
  mkdir -p "$CONFIG_DIR"

  # Set up the virtual environment
  python3 -m venv "$VENV_DIR"
  source "$VENV_DIR/bin/activate"

  # Upgrade pip and install i3pystatus and dependencies
  pip install --upgrade pip
  pip install git+https://github.com/enkore/i3pystatus.git
  pip install python-vlc python-dateutil requests colour geoip2 netifaces psutil i3ipc xkbgroup

  # Deactivate the virtual environment
  deactivate

  # Create a symbolic link for the configuration file
  ln -s -f "$HOME/dotfiles/07-i3pystatus/i3pystatus_ThinkPad_Linux.config" "$CONFIG_DIR/i3pystatus.conf"

  echo "i3pystatus installed successfully."
else
  echo "Skipping i3pystatus installation."
fi
