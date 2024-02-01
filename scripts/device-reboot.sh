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

echo "Reboot device in 30 seconds."
sleep 30
reboot
