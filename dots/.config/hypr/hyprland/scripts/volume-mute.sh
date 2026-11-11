#!/usr/bin/env bash
# Toggles audio mute (sink) or microphone mute (source) and synchronizes the
# internal ALSA hardware mixer so that laptop keyboard mute/micmute LEDs (e.g. on
# ThinkBook / ThinkPad / IdeaPad) accurately match the active PipeWire audio state,
# even when listening through Bluetooth headphones or USB DACs.
#
# Usage:
#   volume-mute.sh [sink|source|mic|sync]
set -u

find_internal_card() {
    local c card_num
    for c in /proc/asound/card[0-9]*; do
        card_num="${c##*card}"
        if amixer -c "$card_num" scontrols 2>/dev/null | grep -q "'Speaker'"; then
            echo "$card_num"
            return 0
        fi
    done
    echo 0
}

TARGET="${1:-sink}"
CARD="$(find_internal_card)"

sync_sink_led() {
    if wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | grep -q "MUTED"; then
        amixer -c "$CARD" -q sset Master mute 2>/dev/null || true
        amixer -c "$CARD" -q sset Speaker mute 2>/dev/null || true
    else
        amixer -c "$CARD" -q sset Master unmute 2>/dev/null || true
        amixer -c "$CARD" -q sset Speaker unmute 2>/dev/null || true
    fi
}

sync_source_led() {
    if wpctl get-volume @DEFAULT_SOURCE@ 2>/dev/null | grep -q "MUTED"; then
        amixer -c "$CARD" -q sset Capture nocap 2>/dev/null || true
    else
        amixer -c "$CARD" -q sset Capture cap 2>/dev/null || true
    fi
}

case "$TARGET" in
    source|mic)
        wpctl set-mute @DEFAULT_SOURCE@ toggle
        sync_source_led
        ;;
    sync)
        sync_sink_led
        sync_source_led
        ;;
    *)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        sync_sink_led
        ;;
esac
