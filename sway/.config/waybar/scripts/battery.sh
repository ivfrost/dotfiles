#!/bin/bash

BAT_PATH="/sys/class/power_supply/BAT0"

if [ ! -d "$BAT_PATH" ]; then
  echo '{"text": "", "tooltip": ""}'
  exit 0
fi

# Read battery data
STATUS=$(cat "$BAT_PATH/status")
ENERGY_NOW=$(cat "$BAT_PATH/energy_now")
ENERGY_FULL=$(cat "$BAT_PATH/energy_full")
ENERGY_FULL_DESIGN=$(cat "$BAT_PATH/energy_full_design")
POWER_NOW=$(cat "$BAT_PATH/power_now")
CAPACITY=$(cat "$BAT_PATH/capacity")

# Calculate health percentage
HEALTH=$((ENERGY_FULL * 100 / ENERGY_FULL_DESIGN))

# Calculate time left
if [ "$POWER_NOW" -gt 0 ]; then
  if [ "$STATUS" = "Discharging" ]; then
    TIME_MINUTES=$((ENERGY_NOW * 60 / POWER_NOW))
  else
    TIME_MINUTES=$(((ENERGY_FULL - ENERGY_NOW) * 60 / POWER_NOW))
  fi
  
  HOURS=$((TIME_MINUTES / 60))
  MINUTES=$((TIME_MINUTES % 60))
  
  if [ "$HOURS" -gt 0 ]; then
    TIME_STR="${HOURS}h ${MINUTES}m"
  else
    TIME_STR="${MINUTES}m"
  fi
else
  TIME_STR="Calculating..."
fi

# Determine icon based on capacity
if [ "$STATUS" = "Charging" ]; then
  ICON=$'\ue0ba'   # battery-charging
elif [ "$STATUS" = "Full" ]; then
  ICON=$'\ue0c0'   # battery-full
elif [ "$CAPACITY" -ge 75 ]; then
  ICON=$'\ue0c2'   # battery-high
elif [ "$CAPACITY" -ge 45 ]; then
  ICON=$'\ue0c6'   # battery-medium
elif [ "$CAPACITY" -ge 15 ]; then
  ICON=$'\ue0c4'   # battery-low
else
  ICON=$'\ue0be'   # battery-empty
fi

# Add charging indicator

# Create tooltip
TOOLTIP="Capacity: ${CAPACITY}%\nHealth: ${HEALTH}%\nTime: ${TIME_STR}\nStatus: ${STATUS}"

# Output JSON
echo "{\"text\":\"<span size='11pt' rise='-4pt'></span>&#8194;<span font='Phosphor' size='17pt' rise='-8pt' weight='500'>${ICON}</span>\",\"tooltip\":\"${TOOLTIP}\"}"