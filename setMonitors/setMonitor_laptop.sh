#!/bin/sh
xrandr --output LVDS-1 --mode 1366x768 --pos 0x0 --rotate normal --output DP-1 --off --output HDMI-1 --off --output VGA-1 --primary --mode 1920x1200 --pos 1366x0 --rotate normal
xrandr --output LVDS-1 --off --output DP-1 --off --output HDMI-1 --off --output VGA-1 --primary --mode 1920x1200 --pos 0x0 --rotate normal
xrandr --output LVDS-1 --off --output DP-1 --off --output HDMI-1 --mode 1920x1080 --pos 1920x0 --rotate left --output VGA-1 --primary --mode 1920x1200 --pos 0x432 --rotate normal
