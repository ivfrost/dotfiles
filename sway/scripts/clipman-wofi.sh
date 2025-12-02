#!/bin/bash

# Get clipboard entries from clipman and add clean history option
selection=$( {
    clipman pick --tool wofi --tool-args="--dmenu --columns 2 -p Clipboard -i"
    echo "🗑️ Clear clipboard history"
} | wofi --dmenu --columns 2 -p "Clipboard" -i )

# Check if user selected the clean history option
if [ "$selection" = "🗑️ Clear clipboard history" ]; then
    clipman clear --all
    notify-send "Clipboard" "History cleared"
else
    # If not, pass the selection back to clipman
    if [ -n "$selection" ]; then
        echo -n "$selection" | wl-copy
    fi
fi
