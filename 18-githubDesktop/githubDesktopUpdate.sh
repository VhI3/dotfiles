#!/bin/bash

# GitHub Desktop Version Checker and Updater
# Script by VHI3

echo "--------🅥 🅗 🅘 ➌-------ᴳⁱᵗᴴᵘᵇ----- {"
# echo "██╗░░░██╗██╗░░██╗██╗██████╗░"
# echo "██║░░░██║██║░░██║██║╚════██╗"
# echo "╚██╗░██╔╝███████║██║░█████╔╝"
# echo "░╚████╔╝░██╔══██║██║░╚═══██╗"
# echo "░░╚██╔╝░░██║░░██║██║██████╔╝"
# echo "░░░╚═╝░░░╚═╝░░╚═╝╚═╝╚═════╝░"
# GitHub API URL for the latest release of GitHub Desktop
API_URL="https://api.github.com/repos/shiftkey/desktop/releases/latest"

# Fetch the latest release version from the GitHub API
# Remove any 'release-' or 'v' prefix from the version
LATEST_VERSION=$(curl -s $API_URL | jq -r '.tag_name' | sed 's/^release-//' | sed 's/^v//')

# Extract the currently installed version of GitHub Desktop
INSTALLED_VERSION=$(apt list --installed | grep github-desktop | grep -oP 'github-desktop/now \K[^\s]+')

# Check if the versions were fetched successfully
if [ -z "$LATEST_VERSION" ] || [ -z "$INSTALLED_VERSION" ]; then
  echo "Error: Unable to determine the versions."
  exit 1
fi

# Display the fetched versions
echo "Latest Version: $LATEST_VERSION"
echo "Installed Version: $INSTALLED_VERSION"

# Compare the fetched versions
if [ "$LATEST_VERSION" = "$INSTALLED_VERSION" ]; then
  echo "Your GitHub Desktop is up-to-date."
else
  echo "A newer version of GitHub Desktop is available."
  # Ask the user if they wish to install the latest version
  read -p "Do you want to install the latest version? (y/N) " response
  if [[ "$response" =~ ^[Yy]$ ]]; then
    # Fetch the download URL for the .deb file for the latest version
    DOWNLOAD_URL=$(curl -s $API_URL | jq -r --arg ver "amd64-$LATEST_VERSION.deb" '.assets[] | select(.name | endswith($ver)) | .browser_download_url')

    # Check if the download URL was found
    if [ -z "$DOWNLOAD_URL" ]; then
      echo "Error: Download URL not found."
      exit 1
    fi

    echo "Downloading GitHub Desktop version $LATEST_VERSION..."
    # Download the .deb file
    curl -LO $DOWNLOAD_URL

    # Extract the filename from the URL
    FILENAME=$(basename $DOWNLOAD_URL)

    # Install the downloaded package
    echo "Installing GitHub Desktop..."
    sudo apt install ./$FILENAME

    # Clean up the downloaded file
    rm $FILENAME
  else
    echo "Update cancelled."
  fi
fi

echo "--------🅥 🅗 🅘 ➌-------ᴳⁱᵗᴴᵘᵇ----- }"
