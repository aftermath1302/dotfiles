#!/usr/bin/env bash

TODO="$HOME/.config/waybar/todo.txt"

touch "$TODO"

case "$1" in

    menu)
        while true; do

            choice=$(rofi -dmenu \
                -i \
                -p "Todo" \
                -mesg "Enter: add • Shift+Space: toggle • Ctrl+Shift+space: remove" \
                -kb-custom-1 "Shift+space" \
                -kb-custom-2 "Control+Shift+space" \
                < "$TODO")

            exit_code=$?

            # Cancel / Escape
            [[ -z "$choice" ]] && exit 0

            # Shift + Space → TOGGLE
            if [[ "$exit_code" -eq 10 ]]; then

                if [[ "$choice" == ✗\ * ]]; then
                    # Completed → unfinished
                    sed -i "s/^✗ //" "$TODO"
                else
                    # Unfinished → completed
                    awk -v task="$choice" '
                        $0 == task {
                            print "✗ " $0
                            next
                        }
                        { print }
                    ' "$TODO" > "$TODO.tmp"

                    mv "$TODO.tmp" "$TODO"
                fi

            # Shift + Q → REMOVE
            elif [[ "$exit_code" -eq 11 ]]; then

                grep -Fxv "$choice" "$TODO" > "$TODO.tmp"
                mv "$TODO.tmp" "$TODO"

            # Enter → ADD
            else

                if [[ -n "$choice" ]]; then
                    echo "$choice" >> "$TODO"
                fi

            fi

        done
        ;;

    add)
        [[ -n "$2" ]] && echo "$2" >> "$TODO"
        exit 0
        ;;

esac

count=$(grep -cve '^[[:space:]]*$' "$TODO")

printf 'Tasks: %s\n' "$count"