#!/bin/bash

LOCK_FILE="/tmp/brightness-popup.lock"
TIMEOUT_PID_FILE="/tmp/brightness-timeout.pid"

# Get current brightness percentage
brightness=$(brightnessctl get)
max=$(brightnessctl max)
percent=$((brightness * 100 / max))

# Write to a temp file that Waybar reads
echo "{\"text\": \"<span size='12pt' weight='400' rise='-2pt'></span> <span size='11pt'>$percent%</span>\"}" > /tmp/waybar-brightness.json

# Kill any previous timeout process
if [ -f "$TIMEOUT_PID_FILE" ]; then
    kill $(cat "$TIMEOUT_PID_FILE") 2>/dev/null
fi

# Start a new timeout in background and save its PID
(sleep 5 && echo "{\"text\": \"\"}" > /tmp/waybar-brightness.json) &
echo $! > "$TIMEOUT_PID_FILE"
