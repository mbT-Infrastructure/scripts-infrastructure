#!/usr/bin/env bash
set -e

DEPENDENCIES=()
DEVICE=""
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# help message
for ARGUMENT in "$@"; do
    if [ "$ARGUMENT" == "-h" ] || [ "$ARGUMENT" == "--help" ]; then
        echo "usage: $(basename "$0") [ARGUMENT]"
        echo "Run Scripts to install a PC-Debian."
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

"${SCRIPT_DIR}/install-base-debian.sh" --device "$DEVICE"
"${SCRIPT_DIR}/install-apt-sources-testing.sh" --device "$DEVICE"
"${SCRIPT_DIR}/device-reboot.sh" --device "$DEVICE"
"${SCRIPT_DIR}/install-locales.sh" --device "$DEVICE"
"${SCRIPT_DIR}/install-desktop-environment.sh" --device "$DEVICE"
"${SCRIPT_DIR}/device-reboot.sh" --device "$DEVICE"
"${SCRIPT_DIR}/install-base-apps.sh" --device "$DEVICE"
"${SCRIPT_DIR}/install-desktop-apps.sh" --device "$DEVICE"
"${SCRIPT_DIR}/install-network.sh" --device "$DEVICE"
"${SCRIPT_DIR}/device-reboot.sh" --device "$DEVICE"
