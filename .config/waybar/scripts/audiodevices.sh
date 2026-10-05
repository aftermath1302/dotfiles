#!/bin/bash

# Get the current default sink
default_sink=$(pactl get-default-sink)

# Get available audio outputs
sinks=$(pactl list short sinks | awk '{print $1 "\t" $2}')

choice=$(echo "$sinks" | while IFS=$'\t' read -r id name; do

    # Mark currently active sink
    marker=" "
    [[ "$name" == "$default_sink" ]] && marker="●"

    case "$name" in
        *analog-stereo*)
            echo -e "$marker 󰕿  Speakers\t$id"
            ;;
        *hdmi-stereo*)
            echo -e "$marker 󰍹  HDMI\t$id"
            ;;
        *)
            echo -e "$marker 󰋋  $name\t$id"
            ;;
    esac

done | rofi -dmenu -i -p "Audio")

[ -z "$choice" ] && exit 0

# Extract sink ID
sink_id=$(echo "$choice" | awk -F '\t' '{print $2}')

# Set selected device as default
pactl set-default-sink "$sink_id"

# Move currently playing applications to it
pactl list short sink-inputs | awk '{print $1}' | while read -r input; do
    pactl move-sink-input "$input" "$sink_id"
done