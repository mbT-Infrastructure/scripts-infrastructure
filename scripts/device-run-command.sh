#!/usr/bin/env bash
set -e

COMMAND=""
DEVICE=""

# help message
for ARGUMENT in "$@"; do
    if [ "$ARGUMENT" == "-h" ] || [ "$ARGUMENT" == "--help" ]; then
        echo "usage: $(basename "$0") [ARGUMENT]"
        echo "Run a command on the local device."
        echo "ARGUMENT can be"
        echo "    --command COMMAND The command to execute."
        echo "    --device DEVICE The device name."
        exit
    fi
done

# check arguments
while [[ -n "$1" ]]; do
    if [[ "$1" == "--command" ]]; then
        shift
        COMMAND="$1"
    elif [[ "$1" == "--device" ]]; then
        shift
        DEVICE="$1"
    else
        echo "Unknown argument: \"$1\""
        exit 1
    fi
    shift
done

if [[ -z "$DEVICE" ]]; then
    echo "Device is required."
    exit 1
fi

if [[ "$DEVICE" == localhost ]]; then
    eval "$COMMAND"
else
    echo "$COMMAND" | ssh "$DEVICE" bash
fi
