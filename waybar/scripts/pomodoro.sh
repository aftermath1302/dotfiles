#!/usr/bin/env bash

STATE="$HOME/.cache/waybar-pomodoro"
CLICK="$HOME/.cache/waybar-pomodoro-click"
mkdir -p "$(dirname "$STATE")"

# status | remaining_seconds | selected_duration_seconds
if [[ ! -f "$STATE" ]]; then
    echo "stopped|1500|1500" > "$STATE"
fi

IFS='|' read -r status seconds duration < "$STATE"

case "$1" in

    click)
        # Second click within 0.3 seconds = change timer
        if [[ -f "$CLICK" ]]; then
            rm -f "$CLICK"
            "$0" menu
            exit 0
        fi

        touch "$CLICK"

        (
            sleep 0.3

            if [[ -f "$CLICK" ]]; then
                rm -f "$CLICK"

                if [[ "$status" == "running" ]]; then
                    echo "paused|$seconds|$duration" > "$STATE"
                else
                    echo "running|$seconds|$duration" > "$STATE"
                fi
            fi
        ) &

        exit 0
        ;;

    reset)
        echo "stopped|$duration|$duration" > "$STATE"
        exit 0
        ;;

    menu)
        choice=$(printf '%s\n' \
            "15 minutes" \
            "25 minutes" \
            "30 minutes" \
            "45 minutes" \
            "60 minutes" \
            "Custom..." |
            rofi -dmenu -i -p "Pomodoro" -mesg "Choose timer duration")

        case "$choice" in
            "15 minutes") minutes=15 ;;
            "25 minutes") minutes=25 ;;
            "30 minutes") minutes=30 ;;
            "45 minutes") minutes=45 ;;
            "60 minutes") minutes=60 ;;

            "Custom...")
                minutes=$(rofi -dmenu \
                    -p "Minutes" \
                    -mesg "Enter timer duration in minutes")

                [[ "$minutes" =~ ^[0-9]+$ ]] || exit 0
                (( minutes > 0 )) || exit 0
                ;;

            *) exit 0 ;;
        esac

        new_duration=$((minutes * 60))
        echo "stopped|$new_duration|$new_duration" > "$STATE"
        exit 0
        ;;
esac

# Countdown
if [[ "$status" == "running" ]]; then
    ((seconds--))

    if (( seconds <= 0 )); then
        seconds=0
        status="stopped"
        notify-send "Pomodoro" "Time's up!" -u normal
    fi

    echo "$status|$seconds|$duration" > "$STATE"
fi

minutes=$((seconds / 60))
secs=$((seconds % 60))

printf '󰔛 %02d:%02d\n' "$minutes" "$secs"