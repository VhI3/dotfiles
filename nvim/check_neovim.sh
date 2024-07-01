#!/bin/bash

# Check if Neovim is installed
if command -v nvim >/dev/null 2>&1; then
    echo "Neovim is installed."
else
    echo "Neovim is not installed."
fi

