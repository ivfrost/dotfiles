#!/bin/bash

WP_FOLDER=~/Pictures/Wallpapers/

FILE=$(find "$WP_FOLDER" -type f \( -name '*.png' -o -name '*.jpg' \) | shuf -n1)

ln -sf "$FILE" ~/.cache/current_wallpaper

pkill -x swaybg
swaybg -i "$FILE" -m fill &