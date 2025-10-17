#!/usr/bin/env bash
set -e

DEVICE=""
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# help message
for ARGUMENT in "$@"; do
    if [ "$ARGUMENT" == "-h" ] || [ "$ARGUMENT" == "--help" ]; then
        echo "usage: $(basename "$0") [ARGUMENT]"
        echo "Add stable sources and update packages."
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

echo "Add apt stable sources on device \"$DEVICE\"."

"${SCRIPT_DIR}/device-run-command.sh" --device "$DEVICE" --command \
    "curl --silent --location --output /etc/apt/sources.list.d/stable-main.sources \
    https://raw.githubusercontent.com/mbT-Infrastructure/template-config-files/main/debian/apt/\
sources-stable-main.sources \
    && rm -f /etc/apt/sources.list.d/stable-main.list /etc/apt/sources.list"
"${SCRIPT_DIR}/maintenance-apt-full-upgrade.sh" --device "$DEVICE"
