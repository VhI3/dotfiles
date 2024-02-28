#!/bin/sh

# Check if DP-2 is connected and its resolution
DP2_STATUS=$(xrandr | grep DP-2 | grep connected)

if echo "$DP2_STATUS" | grep -q "3440x1440"; then
    # Office setup
    xrandr --output eDP-1 --primary --mode 1920x1080 --pos 851x1440 --rotate normal --output DP-1 --off --output HDMI-1 --off --output DP-2 --mode 3440x1440 --pos 0x0 --rotate normal --output HDMI-2 --off
elif echo "$DP2_STATUS" | grep -q "1920x1080"; then
    # Home setup
    xrandr --output eDP-1 --primary --mode 1920x1080 --pos 0x1080 --rotate normal --output DP-1 --off --output HDMI-1 --off --output DP-2 --mode 1920x1080 --pos 0x0 --rotate normal --output HDMI-2 --off
else
    echo "No known monitor configuration found."
fi

