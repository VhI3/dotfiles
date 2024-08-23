#!/bin/bash

# Function to set the dark theme
set_dark_theme() {
  ln -sf ~/dotfiles/09-alacritty/alacritty_dark.toml ~/.config/alacritty/alacritty.toml
  ln -sf ~/dotfiles/19-zathura/zathurarc_dark ~/.config/zathura/zathurarc
  ln -sf ~/dotfiles/nvim/plugins/theme_dark.lua ~/.config/nvim/lua/plugins/theme.lua
  echo "Dark theme applied."
}

# Function to set the light theme
set_light_theme() {
  ln -sf ~/dotfiles/09-alacritty/alacritty_light.toml ~/.config/alacritty/alacritty.toml
  ln -sf ~/dotfiles/19-zathura/zathurarc_light ~/.config/zathura/zathurarc
  ln -sf ~/dotfiles/nvim/plugins/theme_light.lua ~/.config/nvim/lua/plugins/theme.lua
  echo "Light theme applied."
}

# Check if an argument was provided
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <dark|light>"
  exit 1
fi

# Apply the appropriate theme based on the argument
case "$1" in
dark)
  set_dark_theme
  ;;
light)
  set_light_theme
  ;;
*)
  echo "Invalid argument. Use 'dark' or 'light'."
  exit 1
  ;;
esac
