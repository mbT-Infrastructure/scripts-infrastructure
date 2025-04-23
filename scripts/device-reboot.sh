#!/usr/bin/env bash
set -e

DEVICE=""

# help message
for ARGUMENT in "$@"; do
    if [ "$ARGUMENT" == "-h" ] || [ "$ARGUMENT" == "--help" ]; then
        echo "usage: $(basename "$0")"
        echo "Reboot the device."
        echo "ARGUMENT can be"
        echo "    --device DEVICE The device name."
        exit
    fi
done

if [[ "$SKIP_REBOOT" == "true" ]]; then
    echo "SKIP_REBOOT is set to true. Skip reboot."
    exit
fi

# check arguments
while [[ -n "$1" ]]; do
    if [[ "$1" == "--device" ]]; then
        shift
        DEVICE="$1"
    else
        echo "Unknown argument: \"$1\""
        exit 1
    fi
    shift
done

echo "Reboot device "$DEVICE"."

if [[ -z "$DEVICE" ]] || [[ "$DEVICE" == localhost ]]; then
    if [[ "$(id --user)" != 0 ]]; then
        sudo reboot
    else
        reboot
    fi
else
    ssh "$DEVICE" reboot
    while ! ssh "$DEVICE" true; do
        echo "Waiting for device "$DEVICE" to reboot..."
        sleep 5
    done
fi
