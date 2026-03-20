#!/bin/bash

# Show a notification
notify-send "Swap Escape and Caps Lock"

# Swap Escape and Ctrl+Alt
setxkbmap -option caps:swapescape
