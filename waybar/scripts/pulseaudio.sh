#!/bin/bash

output_status() {
  # Get volume and mute status
  VOLUME=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | tr -d '%')
  MUTE=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')

  # Get the default sink to check if it's a headphone
  SINK_NAME=$(pactl get-default-sink)
  SINK_INFO=$(pactl list sinks | grep -A 100 "Name: $SINK_NAME")
  ACTIVE_PORT=$(echo "$SINK_INFO" | grep "Active Port:" | head -1)

  # Only show if it's NOT headphones
  if ! echo "$ACTIVE_PORT" | grep -qiE "headphone|earpiece"; then
    if [ "$MUTE" = "yes" ]; then
      echo "{\"text\":\"<span size='14pt' weight='600' rise='-3pt'></span>\"}"
    else
      # Select icon based on volume level
      if [ "$VOLUME" -le 33 ]; then
        ICON=""
      elif [ "$VOLUME" -le 66 ]; then
        ICON=""
      else
        ICON=""
      fi
      echo "{\"text\":\"<span size='13pt' rise='-2pt' weight='400'>$ICON</span> <span size='11pt'>${VOLUME}%</span>\"}"
    fi
  else
    # Output empty when headphones are connected
    echo "{\"text\":\"\"}"
  fi
}

# Output initial status
output_status

# Listen for pulseaudio events and trigger updates
pactl subscribe | while IFS= read -r line; do
  [[ "$line" == *"sink"* ]] && output_status
done
