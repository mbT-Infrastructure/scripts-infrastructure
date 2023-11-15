#!/usr/bin/env bash
set -e

CONFIG_FILE=""
DEPENDENCIES=()
DEVICE=""
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
USER_USERNAME=""

# help message
for ARGUMENT in "$@"; do
    if [ "$ARGUMENT" == "-h" ] || [ "$ARGUMENT" == "--help" ]; then
        echo "usage: $(basename "$0") [ARGUMENT]"
        echo "Configure personal user settings."
        echo "ARGUMENT can be"
        echo "    --config FILE The config file of the user."
        echo "    --device DEVICE The device name."
        echo "    --user USER The Username of the user."
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
    if [[ "$1" == "--config" ]]; then
        shift
        CONFIG_FILE="$1"
    elif [[ "$1" == "--device" ]]; then
        shift
        DEVICE="$1"
    elif [[ "$1" == "--user" ]]; then
        shift
        USER_USERNAME="$1"
    else
        echo "Unknown argument: \"$1\""
        exit 1
    fi
    shift
done

"${SCRIPT_DIR}/configure-app.sh" --device "$DEVICE" --user "$USER_USERNAME" --app DesktopFiles \
    --config "$CONFIG_FILE"

"${SCRIPT_DIR}/configure-app.sh" --device "$DEVICE" --user "$USER_USERNAME" --app Git \
    --config "$CONFIG_FILE"

"${SCRIPT_DIR}/configure-app.sh" --device "$DEVICE" --user "$USER_USERNAME" --app GSettings \
    --config "$CONFIG_FILE"

"${SCRIPT_DIR}/configure-app.sh" --device "$DEVICE" --user "$USER_USERNAME" --app Gtk \
    --config "$CONFIG_FILE"

"${SCRIPT_DIR}/configure-app.sh" --device "$DEVICE" --user "$USER_USERNAME" --app Linphone \
    --config "$CONFIG_FILE"

"${SCRIPT_DIR}/configure-app.sh" --device "$DEVICE" --user "$USER_USERNAME" --app Locale \
    --config "$CONFIG_FILE"
