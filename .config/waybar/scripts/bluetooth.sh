#!/bin/bash

ROFI="rofi -dmenu -i -p 'Bluetooth'"

bluetoothctl power on >/dev/null 2>&1
bluetoothctl pairable on >/dev/null 2>&1

while true; do

    # Known devices
    devices=$(bluetoothctl devices)

    menu="󰑐  Refresh"

    if [ -n "$devices" ]; then
        menu+="\n$(echo "$devices" | sed 's/^Device //')"
    fi

    choice=$(printf '%b\n' "$menu" | $ROFI)

    [ -z "$choice" ] && exit 0

    # Refresh / discovery
    if [[ "$choice" == "󰑐  Refresh" ]]; then

        # Start discovery
        bluetoothctl --timeout 5 scan on >/tmp/bluetooth-scan.log 2>&1

        continue
    fi

    mac=$(echo "$choice" | awk '{print $1}')

    [ -z "$mac" ] && continue

    # Connected → disconnect
    if bluetoothctl info "$mac" | grep -q "Connected: yes"; then
        bluetoothctl disconnect "$mac" >/dev/null
        continue
    fi

    # Pair
    if ! bluetoothctl info "$mac" | grep -q "Paired: yes"; then
        bluetoothctl pair "$mac"
    fi

    # Connect
    bluetoothctl connect "$mac"

    exit 0
done