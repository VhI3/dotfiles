#!/bin/bash

# Prompt to install Firefox
FirefoxInstall=false
echo "Do you want to install the latest Firefox? (y/n)"
read -n 1 FirefoxInstall
echo
if [ "$FirefoxInstall" == "y" ] || [ "$FirefoxInstall" == "Y" ]; then
  echo "- - - - - - - - - - - - - - - - -"
  echo "- - - - Installing Firefox - - - -"
  echo "- - - - - - - - - - - - - - - - -"

  # Define installation directory
  FIREFOX_DIR="/opt/firefox"

  # Remove existing Firefox installation if it exists
  if [ -d "$FIREFOX_DIR" ]; then
    echo "Removing existing Firefox installation..."
    sudo rm -rf "$FIREFOX_DIR"
  fi

  # Download the latest Firefox package
  echo "Downloading the latest Firefox..."
  wget https://download.mozilla.org/?product=firefox-latest &
  os=linux64 &
  lang=en-US -O firefox.tar.bz2

  # Extract the package and move to the target directory
  echo "Installing Firefox..."
  sudo tar -xjf firefox.tar.bz2 -C /opt
  sudo mv /opt/firefox /opt/firefox

  # Create a symlink to make Firefox globally accessible
  echo "Creating a symlink for Firefox..."
  sudo ln -sf /opt/firefox/firefox /usr/local/bin/firefox

  # Clean up the downloaded package
  echo "Cleaning up..."
  rm -f firefox.tar.bz2

  echo "- - - - - - - - - - - - - - - - -"
  echo "- - - - Firefox Installed Successfully - - -"
  echo "- - - - - - - - - - - - - - - - -"
else
  echo "Firefox installation skipped."
fi
