#!/bin/bash

# Step 3: Add Debian Testing Repositories
if ! grep -q "testing" /etc/apt/sources.list; then
  echo "Adding Debian Testing Repositories..."
  sudo tee -a /etc/apt/sources.list >/dev/null <<EOL
deb http://deb.debian.org/debian testing main contrib non-free
deb-src http://deb.debian.org/debian testing main contrib non-free
EOL
  echo "Configuring package priorities..."
  sudo tee /etc/apt/preferences.d/testing >/dev/null <<EOL
Package: *
Pin: release a=stable
Pin-Priority: 700

Package: *
Pin: release a=testing
Pin-Priority: 650
EOL
fi
