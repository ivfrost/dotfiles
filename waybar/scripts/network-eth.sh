#!/bin/bash

ETHERNET=$(nmcli -t -f DEVICE,TYPE,STATE dev | grep "ethernet:connected" | cut -d: -f1)

if [ -n "$ETHERNET" ]; then
  echo "{\"text\":\"<span size='15pt' weight='400' rise='-18pt'></span>\",\"tooltip\":\"Ethernet: $ETHERNET (connected)\"}"
else
  echo "{\"text\":\"<span size='16pt' weight='400'></span>\",\"tooltip\":\"No network\"}"
fi
