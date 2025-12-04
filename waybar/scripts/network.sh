#!/bin/bash

SSID=$(nmcli -t -f ACTIVE,SSID dev wifi | grep yes | cut -d: -f2)
SIGNAL=$(nmcli -t -f IN-USE,SIGNAL dev wifi | grep "^\*:" | cut -d: -f2)

ETHERNET=$(nmcli -t -f DEVICE,TYPE,STATE dev | grep "ethernet:connected" | cut -d: -f1)

if [ -n "$ETHERNET" ]; then
  ICON=""
  echo "{\"text\":\"<span size='22pt' weight='400' rise='-28pt'>$ICON</span>\",\"tooltip\":\"Ethernet: $ETHERNET (connected)\"}"
elif [ -n "$SSID" ]; then
  if [ "$SIGNAL" -ge 40 ]; then
    ICON=""
  elif [ "$SIGNAL" -ge 30 ]; then
    ICON=""
  else
    ICON=""
  fi
  echo "{\"text\":\"<span size='22pt' weight='400'>$ICON</span>\",\"tooltip\":\"SSID: $SSID\nSignal: $SIGNAL%\"}"
else
  echo "{\"text\":\"<span size='22pt' weight='400'></span>\",\"tooltip\":\"No network\"}"
fi
