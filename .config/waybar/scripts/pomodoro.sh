#!/usr/bin/env bash

STATE="$HOME/.cache/waybar-pomodoro"
CLICK="$HOME/.cache/waybar-pomodoro-click"

mkdir -p "$(dirname "$STATE")"

# State format:
# status | time | duration
#
# stopped | 0            | 1500
# running | end_timestamp| 1500
# paused  | seconds_left | 1500

if [[ ! -f "$STATE" ]]; then
    echo "stopped|0|1500" > "$STATE"
fi

IFS='|' read -r status time duration < "$STATE"


# ==================================================
# CLICK
# ==================================================

case "$1" in

    click)

        # Second click within 0.3 seconds → duration menu
        if [[ -f "$CLICK" ]]; then
            rm -f "$CLICK"
            "$0" menu
            exit 0
        fi


        # First click
        touch "$CLICK"

        (
            sleep 0.3

            if [[ -f "$CLICK" ]]; then
                rm -f "$CLICK"

                IFS='|' read -r current_status current_time current_duration < "$STATE"


                # Stopped → start timer
                if [[ "$current_status" == "stopped" ]]; then

                    now=$(date +%s)
                    end_time=$((now + current_duration))

                    echo "running|$end_time|$current_duration" > "$STATE"


                # Running → pause timer
                elif [[ "$current_status" == "running" ]]; then

                    now=$(date +%s)
                    remaining=$((current_time - now))

                    (( remaining < 0 )) && remaining=0

                    echo "paused|$remaining|$current_duration" > "$STATE"


                # Paused → resume timer
                elif [[ "$current_status" == "paused" ]]; then

                    now=$(date +%s)
                    end_time=$((now + current_time))

                    echo "running|$end_time|$current_duration" > "$STATE"

                fi
            fi

        ) &

        exit 0
        ;;


# ==================================================
# RESET
# ==================================================

    reset)

        # Clear any pending click
        rm -f "$CLICK"

        # Reset to the selected duration
        echo "stopped|0|$duration" > "$STATE"

        exit 0
        ;;


# ==================================================
# DURATION MENU
# ==================================================

    menu)

        choice=$(printf '%s\n' \
            "15 minutes" \
            "25 minutes" \
            "30 minutes" \
            "45 minutes" \
            "60 minutes" \
            "Custom..." |
            rofi -dmenu -i \
                -p "Pomodoro" \
                -mesg "Choose timer duration")


        case "$choice" in

            "15 minutes")
                minutes=15
                ;;

            "25 minutes")
                minutes=25
                ;;

            "30 minutes")
                minutes=30
                ;;

            "45 minutes")
                minutes=45
                ;;

            "60 minutes")
                minutes=60
                ;;

            "Custom...")

                minutes=$(rofi -dmenu \
                    -p "Minutes" \
                    -mesg "Enter timer duration in minutes")

                [[ "$minutes" =~ ^[0-9]+$ ]] || exit 0
                (( minutes > 0 )) || exit 0
                ;;

            *)
                exit 0
                ;;

        esac


        new_duration=$((minutes * 60))

        echo "stopped|0|$new_duration" > "$STATE"

        exit 0
        ;;

esac


# ==================================================
# CALCULATE REMAINING TIME
# ==================================================

if [[ "$status" == "running" ]]; then

    now=$(date +%s)
    seconds=$((time - now))

    if (( seconds <= 0 )); then

        seconds=0
        status="stopped"

        echo "stopped|0|$duration" > "$STATE"

        # Notification runs independently so it
        # can never freeze the Pomodoro.
        (
            timeout 2s notify-send \
                "Pomodoro" \
                "Time's up!" \
                -u normal
        ) >/dev/null 2>&1 &

    fi

elif [[ "$status" == "paused" ]]; then

    seconds="$time"

else

    # Stopped/reset timer shows the full duration
    seconds="$duration"

fi


# ==================================================
# DISPLAY
# ==================================================

minutes=$((seconds / 60))
secs=$((seconds % 60))


# ==================================================
# WAYBAR STATE
# ==================================================

if (( seconds <= 0 )); then
    class="finished"
else
    class="active"
fi


# ==================================================
# WAYBAR JSON
# ==================================================

printf '{"text":"󰔛 %02d:%02d","class":"%s","tooltip":false}\n' \
    "$minutes" \
    "$secs" \
    "$class"
