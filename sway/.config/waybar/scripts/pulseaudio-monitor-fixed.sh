#!/bin/bash

# Central monitor that writes to temp files for both modules
SPEAKERS_FILE="/tmp/waybar-speakers.json"
HEADPHONES_FILE="/tmp/waybar-headphones.json"

output_all() {
  # Get volume and mute status with error handling
  VOLUME=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | awk '{print $5}' | tr -d '%')
  MUTE=$(pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | awk '{print $2}')
  SINK_NAME=$(pactl get-default-sink 2>/dev/null)
  
  # Skip if pactl failed
  if [ -z "$VOLUME" ] || [ -z "$MUTE" ] || [ -z "$SINK_NAME" ]; then
    return
  fi

  # Generate speakers output
  if ! echo "$SINK_NAME" | grep -qiE "headphone|earpiece"; then
    if [ "$MUTE" = "yes" ]; then
      SPEAKERS_OUTPUT="{\"text\":\"Muted \"}"
    else
      SPEAKERS_OUTPUT="{\"text\":\"${VOLUME}% \"}"
    fi
  else
    SPEAKERS_OUTPUT="{\"text\":\"\"}"
  fi

  # Generate headphones output
  if echo "$SINK_NAME" | grep -qiE "headphone|earpiece"; then
    if [ "$MUTE" = "no" ]; then
      HEADPHONES_OUTPUT="{\"text\":\"Headphones ${VOLUME}% \"}"
    else
      HEADPHONES_OUTPUT="{\"text\":\"Headphones Muted \"}"
    fi
  else
    HEADPHONES_OUTPUT="{\"text\":\"\"}"
  fi

  # Write atomically to avoid partial reads
  if [ -n "$SPEAKERS_OUTPUT" ]; then
    echo "$SPEAKERS_OUTPUT" > "$SPEAKERS_FILE.tmp" 2>/dev/null && mv "$SPEAKERS_FILE.tmp" "$SPEAKERS_FILE" 2>/dev/null
  fi
  if [ -n "$HEADPHONES_OUTPUT" ]; then
    echo "$HEADPHONES_OUTPUT" > "$HEADPHONES_FILE.tmp" 2>/dev/null && mv "$HEADPHONES_FILE.tmp" "$HEADPHONES_FILE" 2>/dev/null
  fi
}

# Output initial status
output_all

# Listen for pulseaudio events with reconnection handling
while true; do
  pactl subscribe 2>/dev/null | while IFS= read -r line; do
    if [[ "$line" == *"sink"* ]]; then
      output_all
    fi
  done
  # Reconnect if pactl subscribe fails
  sleep 1
done
