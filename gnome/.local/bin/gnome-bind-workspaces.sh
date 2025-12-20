#!/bin/bash

# Verify Wayland and GNOME environment
if [[ "$XDG_SESSION_TYPE" != "wayland" ]] || ! ps -e | grep -q "gnome-shell"; then
    echo "This script requires GNOME on Wayland"
    exit 1
fi

# Set workspace switching bindings
for i in {1..9}; do
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-$i "['<Alt>$i']"
    gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-$i "['<Alt><Shift>$i']"
done

echo "GNOME Wayland workspace bindings configured successfully!"

