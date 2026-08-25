#!/usr/bin/env bash

COUNTER_FILE="$HOME/.local/state/boot_counter"
TARGET=12

mkdir -p "$HOME/.local/state"

count=$(cat "$COUNTER_FILE" 2>/dev/null || echo 0)
count=$((count + 1))
echo "$count" > "$COUNTER_FILE"

if [[ "$count" -ge "$TARGET" ]]; then
    echo 0 > "$COUNTER_FILE"
    "$HOME/.local/bin/backup_vw.sh"
fi

