#!/bin/sh
set -eu

SETUP_SCRIPT="$HOME/.local/bin/setup-pbcopy.sh"

if [ ! -f "$SETUP_SCRIPT" ]; then
  echo "Missing $SETUP_SCRIPT — put the pbcopy setup script there first."
  exit 1
fi

for ctid in $(pct list | awk 'NR>1 {print $1}'); do
  status=$(pct status "$ctid" | awk '{print $2}')
  started_here=0

  if [ "$status" != "running" ]; then
    echo "Starting CT $ctid..."
    pct start "$ctid"
    started_here=1
    sleep 3
  fi

  echo "Installing pbcopy in CT $ctid..."
  if pct exec "$ctid" -- sh -c "$(cat "$SETUP_SCRIPT")"; then
    echo "CT $ctid done."
  else
    echo "CT $ctid FAILED."
  fi

  if [ "$started_here" -eq 1 ]; then
    echo "Stopping CT $ctid (was previously stopped)..."
    pct stop "$ctid"
  fi
done

echo "All containers processed."
