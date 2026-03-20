#!/bin/bash
set -euo pipefail

echo "==> [05] C/C++ development tools"
sudo apt install -y \
    gcc \
    g++ \
    gdb \
    cmake \
    ninja-build \
    clangd \
    clang-format \
    valgrind \
    make

echo "==> [05] Rust (via rustup — idempotent)"
if ! command -v cargo &>/dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
fi
. "$HOME/.cargo/env"
rustup component add rust-analyzer

echo "==> [05] Done."
