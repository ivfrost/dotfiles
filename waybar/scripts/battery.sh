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
if [ "$CAPACITY" -ge 75 ]; then
  ICON=""
elif [ "$CAPACITY" -ge 45 ]; then
  ICON=""
elif [ "$CAPACITY" -ge 15 ]; then
  ICON=""
else
  ICON=""
fi

# Add charging indicator
if [ "$STATUS" = "Charging" ]; then
  ICON=""
elif [ "$STATUS" = "Full" ]; then
  ICON=""
fi

# Create tooltip
TOOLTIP="Capacity: ${CAPACITY}%\nHealth: ${HEALTH}%\nTime: ${TIME_STR}\nStatus: ${STATUS}"

# Output JSON
echo "{\"text\":\"<span size='11pt'>${CAPACITY}%</span>  <span size='17pt' weight='400' rise='-4pt'>${ICON}</span>\",\"tooltip\":\"${TOOLTIP}\"}"
