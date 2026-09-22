#!/usr/bin/env bash

show_menu() {
    wifi_list=$(nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY device wifi list --rescan no)

    {
        echo "󰑐  Refresh"
        echo "$wifi_list" |
            awk -F: '
            $2 != "" {
                icon=($1=="*") ? "●" : " "
                printf "%s %-25s %3s%%  %s\n", icon, $2, $3, $4
            }'
    } | rofi -dmenu -i -p "Wi-Fi" -mesg "Select a network"
}

while true; do
    selection=$(show_menu)

    [[ -z "$selection" ]] && exit 0

    if [[ "$selection" == "󰑐  Refresh" ]]; then
        # Perform a real scan
        nmcli device wifi rescan

        # Give NetworkManager a moment to populate the results
        sleep 1

        # Reopen the menu with the new list
        continue
    fi

    ssid=$(echo "$selection" |
        sed -E 's/^●? //' |
        sed -E 's/[[:space:]]+[0-9]+%.*$//' |
        sed 's/[[:space:]]*$//')

    # Try saved connection first
    if nmcli connection up "$ssid" 2>/dev/null; then
        exit 0
    fi

    # New network → password prompt
    password=$(rofi -dmenu -password \
        -p "Password" \
        -mesg "$ssid")

    [[ -z "$password" ]] && exit 0

    nmcli device wifi connect "$ssid" password "$password" >/dev/null 2>&1

    exit 0
done