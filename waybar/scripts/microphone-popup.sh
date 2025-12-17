#!/bin/bash

TIMEOUT_PID_FILE="/tmp/microphone-timeout.pid"

# Get microphone volume and mute status
VOLUME=$(pactl get-source-volume @DEFAULT_SOURCE@ | awk '{print $5}' | tr -d '%')
MUTE=$(pactl get-source-mute @DEFAULT_SOURCE@ | awk '{print $2}')

# Select icon based on mute status
if [ "$MUTE" = "yes" ]; then
  echo "{\"text\": \"<span size='12pt' rise='-2pt'></span>\"}" > /tmp/waybar-microphone.json
else
  echo "{\"text\": \"<span size='12pt' rise='-2pt'></span> $VOLUME%\"}" > /tmp/waybar-microphone.json
fi

# Write to a temp file that Waybar reads


# Kill any previous timeout process
if [ -f "$TIMEOUT_PID_FILE" ]; then
    kill $(cat "$TIMEOUT_PID_FILE") 2>/dev/null
fi

# Start a new timeout in background and save its PID
(sleep 5 && rm /tmp/waybar-microphone.json 2>/dev/null) &
echo $! > "$TIMEOUT_PID_FILE"
