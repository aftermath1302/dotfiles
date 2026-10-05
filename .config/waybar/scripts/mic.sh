#!/bin/bash

SOURCE=$(wpctl status | awk '
/Sources:/ { found=1; next }
/Filters:/ { found=0 }
found && /\*/ { 
    sub(/^[[:space:]]*\*[[:space:]]*/, "")
    sub(/[[:space:]]*\[vol:.*/, "")
    print
    exit
}')

MUTE=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q MUTED && echo muted || echo unmuted)

if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q MUTED; then
    echo "󰍭"
else
    echo "󰍬"
fi