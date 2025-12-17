#!/bin/bash
## Requires Hide Top Bar extension for GNOME

status=$(gsettings get org.gnome.shell enabled-extensions)
if [[ "$status" == *'hidetopbar@mathieu.bidon.ca'* ]]; then
  gnome-extensions disable hidetopbar@mathieu.bidon.ca
else
  gnome-extensions enable hidetopbar@mathieu.bidon.ca
fi
