#!/usr/bin/env bash

TODO="$HOME/.config/waybar/todo.txt"

touch "$TODO"

case "$1" in
    menu)
        while true; do
            choice=$(rofi -dmenu \
                -i \
                -p "Todo" \
                -mesg "Enter a task to add • Select a task to remove" \
                < "$TODO")

            [[ -z "$choice" ]] && exit 0

            if grep -Fxq "$choice" "$TODO"; then
                # Remove selected task
                grep -Fxv "$choice" "$TODO" > "$TODO.tmp"
                mv "$TODO.tmp" "$TODO"
            else
                # Add new task
                echo "$choice" >> "$TODO"
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

