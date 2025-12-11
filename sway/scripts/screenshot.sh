#!/bin/bash

SCREENSHOT_FILE="$(xdg-user-dir)/Pictures/Screenshot_$(date +'%Y-%m-%d-%H%M%S.png')"

if [ "$1" == "selection" ]; then
    # Capture selection and copy to clipboard
    grim -g "$(slurp)" "$SCREENSHOT_FILE" && wl-copy < "$SCREENSHOT_FILE"
else
    # Capture full screen
    grim "$SCREENSHOT_FILE"
fi

if [ $? -eq 0 ]; then
    # Show notification with screenshot preview
    notify-send -i "$SCREENSHOT_FILE" "Screenshot" "$SCREENSHOT_FILE"
else
    notify-send "Screenshot failed" "Error taking screenshot"
fi
