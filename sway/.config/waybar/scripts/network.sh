#!/bin/bash

SSID=$(nmcli -t -f ACTIVE,SSID dev wifi | grep yes | cut -d: -f2)
SIGNAL=$(nmcli -t -f IN-USE,SIGNAL dev wifi | grep "^\*:" | cut -d: -f2)
ETHERNET=$(nmcli -t -f DEVICE,TYPE,STATE dev | grep "ethernet:connected" | cut -d: -f1)
WIFI_ICON=$'\ue4ee'
ETH_ICON=$'\uedde'
NONE_ICON=$'\ue4f0'

if [ -n "$ETHERNET" ]; then
  echo "{\"text\":\"<span size='20pt' rise='6pt' weight='400'>$ETH_ICON</span>\",\"tooltip\":\"Ethernet: $ETHERNET\"}"
else
  if [ -n "$SSID" ]; then
    if [ "$SIGNAL" -ge 66 ]; then
      OPACITY="65535"
    elif [ "$SIGNAL" -ge 33 ]; then
      OPACITY="32767"
    else
      OPACITY="16383"
    fi
    echo "{\"text\":\"<span size='22pt' rise='0pt' weight='500' alpha='$OPACITY'>$WIFI_ICON</span>\",\"tooltip\":\"SSID: $SSID\nSignal: $SIGNAL%\"}"
  else
    echo "{\"text\":\"<span size='20pt' rise='0pt' weight='400'>$NONE_ICON</span>\",\"tooltip\":\"No network\"}"
  fi
fi