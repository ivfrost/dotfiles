#!/bin/bash

SPEAKERS_FILE="/tmp/waybar-speakers.json"
HEADPHONES_FILE="/tmp/waybar-headphones.json"

SPEAKER_HIGH=$'\ue44a'
SPEAKER_LOW=$'\ue44c'
SPEAKER_NONE=$'\ue44e'
SPEAKER_MUTE=$'\ue45a'
HEADPHONES=$'\ue2a6'

output_all() {
  VOLUME=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | awk '{print $5}' | tr -d '%')
[ "$VOLUME" -gt 100 ] 2>/dev/null && VOLUME=100
  MUTE=$(pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | awk '{print $2}')
  SINK_NAME=$(pactl get-default-sink 2>/dev/null)

  if [ -z "$VOLUME" ] || [ -z "$MUTE" ] || [ -z "$SINK_NAME" ]; then
    return
  fi

  if ! echo "$SINK_NAME" | grep -qiE "headphone|earpiece"; then
    if [ "$MUTE" = "yes" ]; then
      # speaker-slash is narrow — thin space is enough
      SPEAKERS_OUTPUT="{\"text\":\"<span font='Phosphor-Fill' size='13pt' rise='-2pt' weight='400'>$SPEAKER_MUTE</span>&#8201;<span size='11pt'>${VOLUME}%</span>\"}"
    else
      if [ "$VOLUME" -le 0 ]; then
        ICON="$SPEAKER_NONE"
        SP="&#8201;"   # narrow — thin space
      elif [ "$VOLUME" -le 50 ]; then
        ICON="$SPEAKER_LOW"
        SP="&#8194;"   # medium — en space
      else
        ICON="$SPEAKER_HIGH"
        SP="&#8194;"   # wide — en space
      fi
      SPEAKERS_OUTPUT="{\"text\":\"<span font='Phosphor-Fill' size='13pt' rise='-2pt' weight='400'>$ICON</span>${SP}<span size='11pt'>${VOLUME}%</span>\"}"
    fi
  else
    SPEAKERS_OUTPUT="{\"text\":\"\"}"
  fi

  if echo "$SINK_NAME" | grep -qiE "headphone|earpiece"; then
    if [ "$MUTE" = "yes" ]; then
      HEADPHONES_OUTPUT="{\"text\":\"<span font='Phosphor-Fill' size='14pt' rise='-2pt' weight='400'>$SPEAKER_MUTE</span>&#8201;<span size='11pt'>${VOLUME}%</span>\"}"
    else
      HEADPHONES_OUTPUT="{\"text\":\"<span font='Phosphor-Fill' size='14pt' rise='-2pt' weight='400'>$HEADPHONES</span>&#8194;<span size='11pt'>${VOLUME}%</span>\"}"
    fi
  else
    HEADPHONES_OUTPUT="{\"text\":\"\"}"
  fi

  echo "$SPEAKERS_OUTPUT" > "$SPEAKERS_FILE.tmp" && mv "$SPEAKERS_FILE.tmp" "$SPEAKERS_FILE"
  echo "$HEADPHONES_OUTPUT" > "$HEADPHONES_FILE.tmp" && mv "$HEADPHONES_FILE.tmp" "$HEADPHONES_FILE"
}

output_all

while true; do
  pactl subscribe 2>/dev/null | while IFS= read -r line; do
    output_all
  done
  sleep 1
done