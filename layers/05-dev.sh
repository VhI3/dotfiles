#!/bin/bash
set -euo pipefail

echo "==> [05] C/C++ development tools"

# GCC/G++ — C and C++ compilers
sudo apt install -y gcc g++

# GDB — GNU debugger for C/C++
sudo apt install -y gdb

# CMake — build system generator used by most C/C++ projects
sudo apt install -y cmake

# Ninja — fast build system, used as CMake backend (cmake -G Ninja)
sudo apt install -y ninja-build

# Clangd — C/C++ language server (LSP), used by Neovim for completion/diagnostics
sudo apt install -y clangd

# Clang-format — C/C++ code formatter, used by Neovim conform.nvim
sudo apt install -y clang-format

# Valgrind — memory error detector and profiler for C/C++
sudo apt install -y valgrind

# Make — still required by many legacy C/C++ projects
sudo apt install -y make

echo "==> [05] Lua + LuaRocks"
# Lua 5.1 — required by Neovim (uses LuaJIT which is Lua 5.1 compatible)
sudo apt install -y lua5.1 liblua5.1-dev
# LuaRocks — Lua package manager, built from source to ensure Lua 5.1 target
if ! command -v luarocks &>/dev/null; then
    LUAROCKS_VER="3.12.2"
    wget -q -P /tmp "https://luarocks.org/releases/luarocks-${LUAROCKS_VER}.tar.gz"
    tar -zxpf "/tmp/luarocks-${LUAROCKS_VER}.tar.gz" -C /tmp
    cd "/tmp/luarocks-${LUAROCKS_VER}" && ./configure && make && sudo make install
    sudo luarocks install luasocket
    rm -rf "/tmp/luarocks-${LUAROCKS_VER}" "/tmp/luarocks-${LUAROCKS_VER}.tar.gz"
    cd -
fi

echo "==> [05] Gnuplot"
# Plotting tool used for scientific/data visualization
# apt version is sufficient; old dotfiles built from source for Qt5 which is unnecessary
sudo apt install -y gnuplot

echo "==> [05] Rust (via rustup — idempotent)"
# Rust toolchain manager — also installs cargo, rustc, and rust-std
if ! command -v cargo &>/dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
fi
. "$HOME/.cargo/env"

# rust-analyzer — Rust language server (LSP) for Neovim
rustup component add rust-analyzer

echo "==> [05] Done."
