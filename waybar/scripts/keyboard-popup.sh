#!/bin/bash

TIMEOUT_PID_FILE="/tmp/keyboard-timeout.pid"

# Get active layout using jq
active_layout=$(swaymsg -t get_inputs | jq -r '.[] | select(.type == "keyboard") | .xkb_layout_names[.xkb_active_layout_index]' | head -1)

# Convert layout name to short code
if [[ "$active_layout" == *"English"* ]]; then
    short="en"
elif [[ "$active_layout" == *"Spanish"* ]]; then
    short="es"
else
    short="$active_layout"
fi

# Write to a temp file that Waybar reads
echo "{\"text\": \"<span size='14pt' rise='-3pt'></span> $short\"}" > /tmp/keyboard-popup.json

# Kill any previous timeout process
if [ -f "$TIMEOUT_PID_FILE" ]; then
    kill $(cat "$TIMEOUT_PID_FILE") 2>/dev/null
fi

# Start a new timeout in background and save its PID
(sleep 5 && rm /tmp/keyboard-popup.json 2>/dev/null) &
echo $! > "$TIMEOUT_PID_FILE"
