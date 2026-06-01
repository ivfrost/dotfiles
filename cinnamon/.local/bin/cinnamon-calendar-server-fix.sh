#!/usr/bin/env bash
set -e

TARGET="/usr/lib/cinnamon/cinnamon-calendar-server.py"

# Only patch if the file contains the broken ICal import
if grep -q "gi.require_version('ICal'" "$TARGET"; then
    sudo sed -i \
        -e "s/gi.require_version('ICal'.*/gi.require_version('ECal', '2.0')/" \
        -e "s/from gi.repository import ICal/from gi.repository import ECal/" \
        -e "s/ICal\.Client/ECal.Client/" \
        "$TARGET"
fi

