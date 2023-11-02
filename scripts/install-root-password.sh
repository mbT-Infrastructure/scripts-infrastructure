#!/usr/bin/env bash
set -e

DEVICE=""
ROOT_PASSWORD=""
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# help message
for ARGUMENT in "$@"; do
    if [ "$ARGUMENT" == "-h" ] || [ "$ARGUMENT" == "--help" ]; then
        echo "usage: $(basename "$0") [ARGUMENT]"
        echo "Set the root password."
        echo "ARGUMENT can be"
        echo "    --device DEVICE The device name."
        echo "    --password PASSWORD The new root password."
        exit
    fi
done

# check arguments
while [[ -n "$1" ]]; do
    if [[ "$1" == "--device" ]]; then
        shift
        DEVICE="$1"
    elif [[ "$1" == "--password" ]]; then
        shift
        ROOT_PASSWORD="$1"
    else
        echo "Unknown argument: \"$1\""
        exit 1
    fi
    shift
done

if [[ -z "$ROOT_PASSWORD" ]]; then
    echo "Please set the root password."
    exit 1
fi

"${SCRIPT_DIR}/device-run-command.sh" --device "$DEVICE" --command \
    "yes '${ROOT_PASSWORD}' | passwd root"
