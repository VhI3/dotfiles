#!/bin/bash

PCT=$(brightnessctl info | grep -oP '\d+(?=%)' | tail -1)

FILLED=$(( PCT / 10 ))
EMPTY=$(( 10 - FILLED ))
BAR=$(printf '█%.0s' $(seq 1 $FILLED) 2>/dev/null)$(printf '░%.0s' $(seq 1 $EMPTY) 2>/dev/null)

notify-send \
    -h string:x-canonical-private-synchronous:brightness \
    "󰃞  $BAR" "$PCT%"
