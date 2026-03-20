#!/bin/bash

# Prompt to install fonts
FontInstall=false
echo "Do you want to install fonts? (y/n)"
read -n 1 FontInstall
echo
if [ "$FontInstall" == "y" ] || [ "$FontInstall" == "Y" ]; then
  echo "- - - - - - - - - - - - - - - - -"
  echo "- - - - - Installing Fonts - - - -"
  echo "- - - - - - - - - - - - - - - - -"

  # Update and clean up the system
  sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y

  # Create a temporary directory for font installation
  TEMP_DIR=~/tmp/fonts_install
  mkdir -p "$TEMP_DIR"
  cd "$TEMP_DIR"

  # Install Powerline Fonts
  echo "Cloning and installing Powerline fonts..."
  git clone https://github.com/powerline/fonts.git
  cd fonts
  ./install.sh
  cd "$TEMP_DIR"

  # Install Nerd Fonts
  echo "Cloning and installing Nerd fonts..."
  git clone https://github.com/ryanoasis/nerd-fonts.git
  cd nerd-fonts
  ./install.sh

  # Cleanup temporary files
  echo "Cleaning up temporary files..."
  cd ~
  rm -rf "$TEMP_DIR"

  echo "- - - - - - - - - - - - - - - - -"
  echo "- - - - Fonts Installed Successfully - - -"
  echo "- - - - - - - - - - - - - - - - -"
else
  echo "Font installation skipped."
fi
