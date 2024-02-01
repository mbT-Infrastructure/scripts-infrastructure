#!/usr/bin/env bash
set -e

DEVICE=""
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
USERNAME=""

# help message
for ARGUMENT in "$@"; do
    if [ "$ARGUMENT" == "-h" ] || [ "$ARGUMENT" == "--help" ]; then
        echo "usage: $(basename "$0") [ARGUMENT]"
        echo "Configure default VLC settings."
        echo "ARGUMENT can be"
        echo "    --device DEVICE The device name."
        echo "    --user USER The username of the user."
        exit
    fi
done

# check arguments
while [[ -n "$1" ]]; do
    if [[ "$1" == "--device" ]]; then
        shift
        DEVICE="$1"
    elif [[ "$1" == "--user" ]]; then
        shift
        USERNAME="$1"
    else
        echo "Unknown argument: \"$1\""
        exit 1
    fi
    shift
done

"${SCRIPT_DIR}/configure-app.sh" --device "$DEVICE" --user "$USERNAME" --app VLC --config \
    "https://raw.githubusercontent.com/mbT-Infrastructure/template-config-files/main/debian/vlc/\
vlc.cfg"
