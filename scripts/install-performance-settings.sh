#!/usr/bin/env bash
set -e

DEVICE=""
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# help message
for ARGUMENT in "$@"; do
    if [ "$ARGUMENT" == "-h" ] || [ "$ARGUMENT" == "--help" ]; then
        echo "usage: $(basename "$0") [ARGUMENT]"
        echo "Tune performance settings depending on hardware capabilities."
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

echo "Tune performance settings depending on hardware capabilities on device \"$DEVICE\"."

MEMORY_SIZE_KIB="$("${SCRIPT_DIR}/device-run-command.sh" --device "$DEVICE" --command \
    "awk '/MemTotal/{print \$2}' /proc/meminfo")"

if [[ "$MEMORY_SIZE_KIB" -lt 16000 ]]; then
    echo "Memory size is less than 16 GB. Disable tmpfs mount on /tmp."
    "${SCRIPT_DIR}/device-run-command.sh" --device "$DEVICE" --command "systemctl mask tmp.mount"
fi
