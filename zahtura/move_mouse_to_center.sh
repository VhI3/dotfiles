#!/bin/bash

# Get the window ID of the currently focused window
WINDOW_ID=$(xdotool getwindowfocus)

# Get the PID of the window
WINDOW_PID=$(xdotool getwindowfocus getwindowpid)

# Get the window class name using the PID
WINDOW_CLASS=$(ps -p $WINDOW_PID -o comm=)

# Check if the window class is Zathura
if [[ "$WINDOW_CLASS" == "zathura" ]]; then
  # Get the window geometry
  WINDOW_GEOMETRY=$(xdotool getwindowgeometry --shell $WINDOW_ID)

  # Parse the window geometry
  eval $WINDOW_GEOMETRY

  # Calculate the center position
  CENTER_X=$((X + WIDTH / 2))
  CENTER_Y=$((Y + HEIGHT / 2))

  # Move the mouse to the center of the window
  xdotool mousemove $CENTER_X $CENTER_Y
fi
