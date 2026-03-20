#!/bin/bash

# Define install path
INSTALL_DIR="~/.opt/thunderbird"
THUNDERBIRD_BIN="$INSTALL_DIR/thunderbird"

# Get the currently installed version (if exists)
if [ -x "$THUNDERBIRD_BIN" ]; then
  CURRENT_VERSION=$($THUNDERBIRD_BIN --version | awk '{print $2}')
else
  CURRENT_VERSION="none"
fi

# Get the latest version number from Mozilla's releases
LATEST_VERSION=$(curl -sI "https://download.mozilla.org/?product=thunderbird-latest&os=linux64&lang=en-US" | grep -i "location" | grep -oE "[0-9]+\.[0-9]+(\.[0-9]+)?")

# Install or update Thunderbird
if [ "$CURRENT_VERSION" != "$LATEST_VERSION" ] || [ "$CURRENT_VERSION" == "none" ]; then
  echo "Installing/Updating Thunderbird: $CURRENT_VERSION -> $LATEST_VERSION"

  # Remove old version if it exists
  sudo rm -rf $INSTALL_DIR

  # Download latest Thunderbird
  cd ~/.opt
  wget -O thunderbird.tar.bz2 "https://download.mozilla.org/?product=thunderbird-latest&os=linux64&lang=en-US"

  # Extract and install
  tar xvf thunderbird.tar.bz2
  # mv thunderbird $INSTALL_DIR

  # Remove downloaded archive
  rm -f thunderbird.tar.bz2

  # Create a symlink for easy access
  sudo ln -sf ~/.opt/thunderbird/thunderbird ~/.local/bin/thunderbird

  # Create a desktop launcher
  if [ ! -f ~/.local/share/applications/thunderbird.desktop ]; then
    echo "Creating Thunderbird desktop launcher..."
    sudo tee ~/.local/share/applications/thunderbird.desktop >/dev/null <<EOL
[Desktop Entry]
Name=Thunderbird
GenericName=Email Client
Exec=~/.local/bin/thunderbird
Icon=$INSTALL_DIR/chrome/icons/default/default128.png
Terminal=false
Type=Application
Categories=Network;Email;
StartupWMClass=thunderbird
EOL
  fi

  # Show installed version
  $THUNDERBIRD_BIN --version
else
  echo "Thunderbird is already up-to-date (version: $CURRENT_VERSION)"
fi
