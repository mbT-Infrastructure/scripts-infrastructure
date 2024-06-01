#!/usr/bin/env bash
set -e

DEVICE=""
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# help message
for ARGUMENT in "$@"; do
    if [ "$ARGUMENT" == "-h" ] || [ "$ARGUMENT" == "--help" ]; then
        echo "usage: $(basename "$0") [ARGUMENT]"
        echo "Run Scripts to install the base of debian installs."
        echo "ARGUMENT can be"
        echo "    --device DEVICE The device name."
        exit
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

"${SCRIPT_DIR}/maintenance-remove-unwanted-apps.sh" --device "$DEVICE"
"${SCRIPT_DIR}/install-apt-sources-stable.sh" --device "$DEVICE"
"${SCRIPT_DIR}/install-hostname.sh" --device "$DEVICE"
"${SCRIPT_DIR}/install-sysctl-conf.sh" --device "$DEVICE"
"${SCRIPT_DIR}/install-install-autonomous.sh" --device "$DEVICE"
"${SCRIPT_DIR}/install-apps.sh" --device "$DEVICE" --apps Backgrounds
"${SCRIPT_DIR}/install-grub.sh" --device "$DEVICE"
"${SCRIPT_DIR}/device-reboot.sh" --device "$DEVICE"
