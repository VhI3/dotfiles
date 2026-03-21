#!/bin/bash

# Get a list of available sinks (audio outputs)
sinks=($(pactl list short sinks | awk '{print $2}'))

# Get the current default sink by name
current_sink=$(pactl get-default-sink)

# Ensure the current sink exists in the list, else default to the first sink
if [[ ! " ${sinks[@]} " =~ " ${current_sink} " ]]; then
  current_sink=${sinks[0]}
fi

# Find the next sink in the list (loop around when reaching the end)
for i in "${!sinks[@]}"; do
  if [[ "${sinks[$i]}" == "$current_sink" ]]; then
    next_index=$(((i + 1) % ${#sinks[@]})) # Get the next index in the list
    next_sink="${sinks[$next_index]}"
    break
  fi
done

# Ensure a valid sink is found before switching
if [[ -z "$next_sink" ]]; then
  notify-send -u critical "Audio Error" "No valid sink found!"
  exit 1
fi

# Set the new default sink using its name
pactl set-default-sink "$next_sink"

# Move active audio streams to the new output
pactl list short sink-inputs | awk '{print $1}' | while read -r input; do
  pactl move-sink-input "$input" "$next_sink"
done

# Get the description of the new sink for a notification
sink_name=$(pactl list sinks | grep -A 10 "Name: $next_sink" | grep "Description" | cut -d ' ' -f2-)

# Show notification with the new sink
notify-send -h string:x-canonical-private-synchronous:audio -u low "Audio Output" "$sink_name"
