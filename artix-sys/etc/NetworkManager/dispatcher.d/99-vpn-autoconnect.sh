#!/bin/sh
INTERFACE=$1
ACTION=$2
# Moved to a persistent system directory that survives reboots
DATA_FILE="/var/lib/NetworkManager/last_vpn_identity"

# Save last VPN connection ID
if [ "$ACTION" = "vpn-up" ]; then
    echo "$CONNECTION_ID" > "$DATA_FILE"
fi

# Reconnect to last VPN on new established connection 
if [ "$ACTION" = "up" ]; then
    case "$INTERFACE" in
        tun*|tap*|wg*)
            ;;
        *)
            if [ -f "$DATA_FILE" ]; then
                LAST_VPN=$(cat "$DATA_FILE")
                if [ -n "$LAST_VPN" ]; then
                    sleep 3
                    nmcli connection up id "$LAST_VPN"
                fi
            fi
            ;;
    esac
fi
