#!/usr/bin/env bash

while true; do

    selection=$(
        {
            echo "󰑐  Refresh"

            nmcli -t --escape no \
                -f IN-USE,SSID,SIGNAL,SECURITY \
                device wifi list --rescan no |
            while IFS=: read -r inuse ssid signal security; do

                [[ -z "$ssid" ]] && continue

                if [[ "$inuse" == "*" ]]; then
                    printf "●  %-30s %3s%%  %s\n" \
                        "$ssid" "$signal" "$security"
                else
                    printf "○  %-30s %3s%%  %s\n" \
                        "$ssid" "$signal" "$security"
                fi

            done

        } |
        rofi -dmenu -i -p "Wi-Fi"
    )

    [[ -z "$selection" ]] && exit 0

    # Refresh
    if [[ "$selection" == "󰑐  Refresh" ]]; then
        nmcli device wifi rescan
        sleep 2
        continue
    fi

    # Remove connection indicator
    network="${selection#●  }"
    network="${network#○  }"

    # Extract SSID
    ssid=$(printf '%s\n' "$network" |
        sed -E 's/[[:space:]]+[0-9]+%[[:space:]]+.*$//' |
        sed 's/[[:space:]]*$//')

    # Existing saved connection
    if nmcli connection show "$ssid" >/dev/null 2>&1; then
        if nmcli connection up "$ssid" >/dev/null 2>&1; then
            exit 0
        fi
    fi

    # Password
    password=$(
        rofi -dmenu -password \
            -p "Password" \
            -mesg "$ssid"
    )

    [[ -z "$password" ]] && exit 0

    # Connect
    if nmcli device wifi connect "$ssid" \
        password "$password" >/dev/null 2>&1; then
        exit 0
    fi

    rofi -e "Failed to connect to $ssid"

done