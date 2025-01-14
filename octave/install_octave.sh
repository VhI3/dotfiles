#!/bin/bash

# Octave version to install
OCTAVE_VERSION="9.3.0"

# Set installation directory
INSTALL_DIR="$HOME/.opt/octave"

# Exit script on any error
set -e

# Function to print messages
function print_message() {
  echo -e "\n====> $1\n"
}

# Update package list and install dependencies
print_message "Installing required dependencies"
sudo apt update
sudo apt install -y \
  g++ gfortran make libblas-dev liblapack-dev libreadline-dev libncurses5-dev \
  libcurl4-gnutls-dev libfftw3-dev libgl1-mesa-dev libglu1-mesa-dev libpng-dev \
  libz-dev gnuplot libx11-dev libfltk1.3-dev libqhull-dev libhdf5-dev \
  libgraphicsmagick++1-dev libjava3d-java libopenblas-dev build-essential \
  libbz2-dev libqrupdate-dev libarpack2-dev libsundials-dev libqscintilla2-qt5-dev \
  libglpk-dev icoutils rapidjson-dev portaudio19-dev python3 python3-pip

# Install SymPy for symbolic package support
print_message "Installing Python SymPy using python3 -m pip"
python3 -m pip install --user sympy

# Create installation directory
print_message "Creating installation directory at $INSTALL_DIR"
mkdir -p "$INSTALL_DIR"

# Download and extract Octave source code
print_message "Downloading Octave $OCTAVE_VERSION source code"
wget "https://ftp.gnu.org/gnu/octave/octave-${OCTAVE_VERSION}.tar.gz" -O "/tmp/octave-${OCTAVE_VERSION}.tar.gz"
tar -xvzf "/tmp/octave-${OCTAVE_VERSION}.tar.gz" -C "/tmp"

# Configure, build, and install Octave
print_message "Configuring Octave"
cd "/tmp/octave-${OCTAVE_VERSION}"
./configure --prefix="$INSTALL_DIR" --enable-jit

print_message "Building Octave"
make -j$(nproc)

print_message "Installing Octave to $INSTALL_DIR"
make install

# Add Octave to PATH
print_message "Adding Octave to PATH"
echo "export PATH=\"$INSTALL_DIR/bin:\$PATH\"" >>"$HOME/.bashrc"
source "$HOME/.bashrc"

# Verify installation
print_message "Verifying Octave installation"
octave --version

# Install and load the symbolic package
print_message "Installing the symbolic package in Octave"
octave --eval "pkg install -forge symbolic"

print_message "Loading the symbolic package in Octave"
octave --eval "pkg load symbolic"

# Install and load the statistics package
print_message "Installing the statistics package in Octave"
octave --eval "pkg install -forge statistics"

print_message "Loading the statistics package in Octave"
octave --eval "pkg load statistics"

print_message "Octave installation with symbolic and statistics packages completed successfully!"
