#!/usr/bin/env bash

show_menu() {
    wifi_list=$(nmcli -t -f IN-USE,BSSID,SSID,SIGNAL,SECURITY,FREQ device wifi list --rescan no)

    {
        echo "󰑐  Refresh"

        echo "$wifi_list" |
            awk -F: '
            $3 != "" {
                icon=($1=="*") ? "●" : " "
                band=($6 >= 5000) ? "5GHz" : "2.4GHz"

                printf "%s %-25s %3s%%  %-8s %s|%s\n",
                    icon, $3, $4, band, $5, $2
            }'
    } | rofi -dmenu -i -p "Wi-Fi" -mesg "Select a network"
}

while true; do
    selection=$(show_menu)

    [[ -z "$selection" ]] && exit 0

    if [[ "$selection" == "󰑐  Refresh" ]]; then
        nmcli device wifi rescan
        sleep 2
        continue
    fi

    # Extract BSSID from the end of the selected line
    bssid=$(echo "$selection" | awk -F'|' '{print $2}')

    # Remove BSSID from the displayed selection
    network=$(echo "$selection" | awk -F'|' '{print $1}')

    # Extract SSID
    ssid=$(echo "$network" |
        sed -E 's/^●? //' |
        sed -E 's/[[:space:]]+[0-9]+%.*$//' |
        sed -E 's/[[:space:]]*$//')

    # Try the existing NetworkManager profile first,
    # but only if it is associated with the selected BSSID.
    if nmcli connection show "$ssid" >/dev/null 2>&1; then
        if nmcli connection modify "$ssid" 802-11-wireless.bssid "$bssid" 2>/dev/null &&
           nmcli connection up "$ssid" >/dev/null 2>&1; then
            exit 0
        fi
    fi

    password=$(rofi -dmenu -password \
        -p "Password" \
        -mesg "$ssid")

    [[ -z "$password" ]] && exit 0

    # Connect directly to the selected access point.
    if nmcli device wifi connect "$ssid" \
        password "$password" \
        bssid "$bssid" >/dev/null 2>&1; then
        exit 0
    fi

    # Connection failed — show an error and let the user try again.
    rofi -e "Failed to connect to $ssid"
done