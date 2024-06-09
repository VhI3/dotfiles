#!/bin/bash

# Function to fetch the latest CMake version from GitHub
fetch_latest_cmake_version() {
	echo "Fetching the latest CMake version from GitHub..."
	curl -s https://api.github.com/repos/Kitware/CMake/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
}

# Function to get the currently installed CMake version
get_local_cmake_version() {
	cmake --version 2>/dev/null | grep version | awk '{print $3}'
}

# Function to install CMake
install_cmake() {
	local version=$1
	echo "Installing CMake version $version..."
	wget "https://github.com/Kitware/CMake/releases/download/$version/cmake-$version.tar.gz" -P ~/tmp/
	tar -zxvf ~/tmp/cmake-$version.tar.gz -C ~/tmp/
	cd ~/tmp/cmake-$version/ || exit
	./bootstrap && make -j$(nproc) && sudo make install
	cd ~ || exit
	rm -rf ~/tmp/cmake*
	echo "CMake $version installation completed."
}

echo "Checking CMake installation..."
latest_version=$(fetch_latest_cmake_version)
local_version=$(get_local_cmake_version)

echo "Latest CMake version: $latest_version"
echo "Installed CMake version: $local_version"

if [ "$local_version" != "$latest_version" ]; then
	echo "A new version of CMake is available."
	mkdir -p ~/tmp
	install_cmake "$latest_version"
else
	echo "The latest version of CMake is already installed."
fi
