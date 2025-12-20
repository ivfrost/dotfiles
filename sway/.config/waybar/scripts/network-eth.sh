#!/bin/bash

ETHERNET=$(nmcli -t -f DEVICE,TYPE,STATE dev | grep "ethernet:connected" | cut -d: -f1)

if [ -n "$ETHERNET" ]; then
  echo "{\"text\":\"<span size='17pt' weight='400'></span>\",\"tooltip\":\"Ethernet: $ETHERNET (connected)\"}"
else
  echo "{\"text\":\"\",\"tooltip\":\"\"}"
fi
