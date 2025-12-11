#!/bin/bash
# by xircon

current=$(swaymsg -t get_workspaces | jq '.[] | select(.focused==true).name' | cut -d"\"" -f2)
monocle=99

if [[ "$current" != "$monocle" ]]; then
    swaymsg move container to workspace $monocle
    swaymsg workspace $monocle
    echo $current > /tmp/current
else
    prev=$(</tmp/current)
    swaymsg move container to workspace $prev
    swaymsg workspace $prev 
    rm /tmp/current # Remove temp file.
fi     