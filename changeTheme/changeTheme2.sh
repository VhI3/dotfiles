#!/bin/bash

# Function to set the dark theme
set_dark_theme() {
  echo "Dark theme applied."
}

# Function to set the light theme
set_light_theme() {
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
