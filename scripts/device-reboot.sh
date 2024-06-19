#!/usr/bin/env bash
set -e

# help message
for ARGUMENT in "$@"; do
    if [ "$ARGUMENT" == "-h" ] || [ "$ARGUMENT" == "--help" ]; then
        echo "usage: $(basename "$0")"
        echo "Reboot the local device."
        exit
    fi
done

# Check if run as root
if [[ "$(id --user)" != 0 ]]; then
    echo "Script must run as root"
    if [[ -n "$(which sudo)" ]];then
        echo "Try with sudo"
        sudo "$0" "$@"
        exit
    fi
    exit 1
fi

if [[ "$SKIP_REBOOT" == "true" ]]; then
    echo "SKIP_REBOOT is set to true. Skip reboot."
    exit
fi

echo "Reboot device in 5 seconds."
sleep 5
reboot
