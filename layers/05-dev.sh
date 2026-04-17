#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/lib-package-manager.sh"

echo "==> [05] C/C++ development tools"

# GCC/G++ — C and C++ compilers
pm_install gcc g++

# GDB — GNU debugger for C/C++
pm_install gdb

# CMake — build system generator used by most C/C++ projects
pm_install cmake

# Ninja — fast build system, used as CMake backend (cmake -G Ninja)
pm_install ninja-build

# Clangd — C/C++ language server (LSP), used by Neovim for completion/diagnostics
pm_install clangd

# Clang-format — C/C++ code formatter, used by Neovim conform.nvim
pm_install clang-format

# Valgrind — memory error detector and profiler for C/C++
pm_install valgrind

# Make — still required by many legacy C/C++ projects
pm_install make

echo "==> [05] Lua + LuaRocks"
# Lua 5.1 — required by Neovim (uses LuaJIT which is Lua 5.1 compatible)
pm_install lua5.1 liblua5.1-dev
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
pm_install gnuplot

echo "==> [05] Rust (via rustup — idempotent)"
# Rust toolchain manager — also installs cargo, rustc, and rust-std
if ! command -v cargo &>/dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
fi
. "$HOME/.cargo/env"

# rust-analyzer — Rust language server (LSP) for Neovim
rustup component add rust-analyzer

echo "==> [05] Done."
