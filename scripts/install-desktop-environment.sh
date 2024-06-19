#!/usr/bin/env bash
set -e

DEVICE=""
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# help message
for ARGUMENT in "$@"; do
    if [ "$ARGUMENT" == "-h" ] || [ "$ARGUMENT" == "--help" ]; then
        echo "usage: $(basename "$0") [ARGUMENT]"
        echo "Install a desktop environent."
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

"${SCRIPT_DIR}/device-run-command.sh" --device "$DEVICE" --command \
    "export DEBIAN_FRONTEND=noninteractive && \
    apt update -qq && apt install -y -qq cinnamon numlockx && \
    curl --silent --location --output /etc/lightdm/lightdm.conf \
    https://raw.githubusercontent.com/mbT-Infrastructure/template-config-files/main/debian/lightdm/\
lightdm.conf"
