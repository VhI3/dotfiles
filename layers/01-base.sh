#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> [01] Base packages"
sudo apt update && sudo apt upgrade -y
sudo apt install -y nala

. "$SCRIPT_DIR/lib-package-manager.sh"

# Core utilities
pm_install git curl wget unzip

# Compiler toolchain — required to build anything from source
pm_install build-essential

# TLS certs + repo management
pm_install ca-certificates software-properties-common

# AppImage support — required to run Neovim AppImage
pm_install libfuse2

# JSON parsing — used by install scripts and lazygit version detection
pm_install jq

# Process viewer
pm_install htop

# Recursive directory listing (used alongside eza for legacy scripts)
pm_install tree

# Intel CPU microcode updates — stability and security fixes (ThinkPad/workstation)
pm_install intel-microcode

# Python — used by Neovim plugins (LSP, DAP, etc.)
pm_install python3 python3-pip python3-venv

echo "==> [01] SSD optimization"
# Enable periodic TRIM — prevents SSD write amplification over time
sudo systemctl enable fstrim.timer

echo "==> [01] Node.js via nvm"
# nvm lets you switch Node versions per project; avoids system Node version conflicts
# Node is required by several Neovim LSP servers (tsserver, pyright, etc.)
if [ ! -d "$HOME/.nvm" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
fi
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
nvm install --lts
nvm use --lts

echo "==> [01] Rust via rustup"
# rustup manages Rust toolchains; cargo is required for eza and rust-analyzer
if ! command -v cargo &>/dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
fi
. "$HOME/.cargo/env"

echo "==> [01] Done."
