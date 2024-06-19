#!/usr/bin/env bash
set -e

DEPENDENCIES=()
DEVICE=""
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# help message
for ARGUMENT in "$@"; do
    if [ "$ARGUMENT" == "-h" ] || [ "$ARGUMENT" == "--help" ]; then
        echo "usage: $(basename "$0") [ARGUMENT]"
        echo "Remove unwanted apps."
        echo "ARGUMENT can be"
        echo "    --device DEVICE The device name."
        exit
    fi
done


# check dependencies
for CMD in "${DEPENDENCIES[@]}"; do
    if [[ -z "$(which "$CMD")" ]]; then
        echo "\"${CMD}\" is missing!"
        exit 1
    fi
done

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

echo "Remove unwanted apps on device \"$DEVICE\"."

"${SCRIPT_DIR}/device-run-command.sh" --device "$DEVICE" --command \
    "apt purge -qq -y deja-dup evince gedit gnome-2048 gnome-system-monitor gnote hexchat \
    pidgin rhythmbox thunderbird totem xorriso"
