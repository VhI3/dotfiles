#!/bin/bash
set -euo pipefail

echo "==> [01] Base packages"
sudo apt update && sudo apt upgrade -y
sudo apt install -y \
    git \
    curl \
    wget \
    unzip \
    build-essential \
    ca-certificates \
    software-properties-common \
    python3 \
    python3-pip \
    python3-venv

echo "==> [01] Node.js via nvm"
if [ ! -d "$HOME/.nvm" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
fi
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
nvm install --lts
nvm use --lts

echo "==> [01] Rust via rustup"
if ! command -v cargo &>/dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
fi
. "$HOME/.cargo/env"

echo "==> [01] Done."
