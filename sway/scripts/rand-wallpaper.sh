#!/bin/sh

# Wallpaper directory
WP_FOLDER=~/Pictures/Wallpapers/

# Pick one random file
FILE=$(find "$WP_FOLDER" -type f \( -name '*.png' -o -name '*.jpg' \) | shuf -n1)

# Save it to cache for swaylock
ln -sf "$FILE" ~/.cache/current_wallpaper

# Set it as wallpaper
swaybg -i "$FILE" -m fill &

