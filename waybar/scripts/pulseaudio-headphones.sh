#!/bin/bash

output_status() {
  # Get volume and mute status
  VOLUME=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | tr -d '%')
  MUTE=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')

  # Get the default sink to check if it's a headphone
  SINK_NAME=$(pactl get-default-sink)
  SINK_INFO=$(pactl list sinks | grep -A 100 "Name: $SINK_NAME")
  ACTIVE_PORT=$(echo "$SINK_INFO" | grep "Active Port:" | head -1)

  # Only show if it's headphones AND not muted
  if echo "$ACTIVE_PORT" | grep -qiE "headphone|earpiece"; then
    if [ "$MUTE" = "no" ]; then
      echo "{\"text\":\"<span size='14pt' rise='-3pt' weight='600'></span>  ${VOLUME}%\"}"
    fi
  else
    # Output empty when headphones are not connected
    echo "{\"text\":\"\"}"
  fi
}

# Output initial status
output_status

# Listen for pulseaudio events and update on change
pactl subscribe | while IFS= read -r line; do
  [[ "$line" == *"sink"* ]] && output_status
done
