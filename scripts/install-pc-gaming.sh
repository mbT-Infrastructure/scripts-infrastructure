#!/usr/bin/env bash
set -e

DEPENDENCIES=()
DEVICE=""
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# help message
for ARGUMENT in "$@"; do
    if [ "$ARGUMENT" == "-h" ] || [ "$ARGUMENT" == "--help" ]; then
        echo "usage: $(basename "$0") [ARGUMENT]"
        echo "Run Scripts to install a PC-Gaming."
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

"${SCRIPT_DIR}/install-pc-debian.sh" --device "$DEVICE"
"${SCRIPT_DIR}/install-apps.sh" --device "$DEVICE" --apps \
    "Steam"
"${SCRIPT_DIR}/configure-user-default.sh" --device "$DEVICE" --user user
"${SCRIPT_DIR}/device-run-command.sh" --device "$DEVICE" --command  \
    "echo 'autologin-user=user' >> /etc/lightdm/lightdm.conf"
"${SCRIPT_DIR}/device-run-command.sh" --device "$DEVICE" --command  \
    "passwd --delete user"
"${SCRIPT_DIR}/device-reboot.sh" --device "$DEVICE"
