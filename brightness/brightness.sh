#!/bin/bash

brightness_file="/sys/class/backlight/intel_backlight/brightness"
max_brightness=$(cat /sys/class/backlight/intel_backlight/max_brightness)

if [[ "$1" == "up" ]]; then
  current=$(cat $brightness_file)
  new=$((current + max_brightness / 10))
  [ "$new" -gt "$max_brightness" ] && new=$max_brightness
  echo $new >$brightness_file
elif [[ "$1" == "down" ]]; then
  current=$(cat $brightness_file)
  new=$((current - max_brightness / 10))
  [ "$new" -lt 1 ] && new=1
  echo $new >$brightness_file
fi

# Calculate brightness percentage
brightness_percent=$((new * 100 / max_brightness))

# Update notification instead of creating new ones
dunstify -r 91190 -u low "Brightness: $brightness_percent%" -h int:value:$brightness_percent
