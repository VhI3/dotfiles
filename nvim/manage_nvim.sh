#!/bin/bash

# Function to check if Neovim is installed and get its version
get_installed_neovim_version() {
    if command -v nvim >/dev/null 2>&1; then
        nvim --version | head -n 1 | awk '{print $2}'
    else
        echo "none"
    fi
}

# Function to fetch the latest Neovim version from GitHub
fetch_latest_neovim_version() {
    curl -s https://api.github.com/repos/neovim/neovim/releases/latest | grep -Po '"tag_name": "\K.*?(?=")'
}

# Function to download the latest Neovim AppImage
download_neovim_appimage() {
    local version="$1"
    local url="https://github.com/neovim/neovim/releases/download/${version}/nvim.appimage"
    if ! wget "$url" -O nvim.appimage; then
        echo "Failed to download Neovim AppImage. Please check your network connection."
        exit 1
    fi
}

# Function to install Neovim AppImage
install_neovim_appimage() {
    mkdir -p ~/.opt/nvim
    mv nvim.appimage ~/.opt/nvim/
    chmod u+x ~/.opt/nvim/nvim.appimage
    mkdir -p ~/.local/bin
    ln -sf ~/.opt/nvim/nvim.appimage ~/.local/bin/nvim
    echo "Neovim $1 installed successfully."
}

# Function to compare versions
version_compare() {
    if [ "$1" = "$2" ]; then
        return 0
    fi

    local IFS=.
    local i ver1=($1) ver2=($2)
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++)); do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++)); do
        if [ -z "${ver2[i]}" ]; then
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]})); then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]})); then
            return 2
        fi
    done
    return 0
}

# Main script logic
installed_version=$(get_installed_neovim_version)
latest_version=$(fetch_latest_neovim_version)

if [ "$installed_version" == "none" ]; then
    echo "Neovim is not installed."
    read -p "Do you want to install the latest version of Neovim ($latest_version)? (y/n) " response
    if [[ "$response" == "y" || "$response" == "Y" ]]; then
        echo "Downloading Neovim $latest_version..."
        download_neovim_appimage "$latest_version"
        install_neovim_appimage "$latest_version"
    else
        echo "Installation aborted by user."
    fi
else
    version_compare "$installed_version" "$latest_version"
    compare_result=$?
    if [ $compare_result -eq 2 ]; then
        echo "Neovim installed version: $installed_version"
        echo "Neovim latest version: $latest_version"
        read -p "Do you want to update to the latest version? (y/n) " response
        if [[ "$response" == "y" || "$response" == "Y" ]]; then
            echo "Downloading Neovim $latest_version..."
            download_neovim_appimage "$latest_version"
            install_neovim_appimage "$latest_version"
        else
            echo "Update aborted by user."
        fi
    else
        echo "Neovim is up-to-date (version $installed_version)."
    fi
fi

