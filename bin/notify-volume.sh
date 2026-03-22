#!/bin/bash

VOL=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | head -1)
MUTED=$(pactl get-sink-mute @DEFAULT_SINK@ | grep -c yes)

if [ "$MUTED" -eq 1 ]; then
    ICON="󰝟"
    BAR="░░░░░░░░░░"
    LABEL="Muted"
elif [ "$VOL" -ge 70 ]; then
    ICON="󰕾"
elif [ "$VOL" -ge 30 ]; then
    ICON="󰖀"
else
    ICON="󰕿"
fi

if [ "$MUTED" -eq 0 ]; then
    FILLED=$(( VOL / 10 ))
    EMPTY=$(( 10 - FILLED ))
    BAR=$(printf '█%.0s' $(seq 1 $FILLED) 2>/dev/null)$(printf '░%.0s' $(seq 1 $EMPTY) 2>/dev/null)
    LABEL="$VOL%"
fi

notify-send \
    -h string:x-canonical-private-synchronous:volume \
    "$ICON  $BAR" "$LABEL"
