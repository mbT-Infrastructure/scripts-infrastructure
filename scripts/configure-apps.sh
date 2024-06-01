#!/usr/bin/env bash
set -e

APPS=""
CONFIG_FILE=""
DEPENDENCIES=(download.sh)
DEVICE=""
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
USERNAME=""
WORKING_DIR="${PWD}/.temp-$(basename "$0")"

# help message
for ARGUMENT in "$@"; do
    if [ "$ARGUMENT" == "-h" ] || [ "$ARGUMENT" == "--help" ]; then
        echo "usage: $(basename "$0") [ARGUMENT]"
        echo "Configure apps with the install-autonomous.sh script."
        echo "ARGUMENT can be"
        echo "    --apps APPS The names of the apps."
        echo "    --config PATH The path to the config file."
        echo "    --device DEVICE The device name."
        echo "    --user USER The username of the user."
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
    if [[ "$1" == --app?(s) ]]; then
        shift
        APPS="$1"
    elif [[ "$1" == "--config" ]]; then
        shift
        CONFIG_FILE="$1"
    elif [[ "$1" == "--device" ]]; then
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

if [[ -e "$WORKING_DIR" ]]; then
    echo "\"${WORKING_DIR}\" exists already. Removing in 10 seconds."
    sleep 10
    rm -f -r "$WORKING_DIR"
fi
mkdir "$WORKING_DIR"

if [[ "$CONFIG_FILE" == "http://"* ]] || [[ "$CONFIG_FILE" == "https://"* ]]; then
    download.sh --name "${WORKING_DIR}/install-autonomous-config.cfg" "$CONFIG_FILE"
else
    cp "$CONFIG_FILE" "${WORKING_DIR}/install-autonomous-config.cfg"
fi

cd "$WORKING_DIR"

"${SCRIPT_DIR}/device-upload-file.sh" --device "$DEVICE" --file install-autonomous-config.cfg \
    --target /tmp

"${SCRIPT_DIR}/device-run-command.sh" --device "$DEVICE" --command \
    "chown $USERNAME /tmp/install-autonomous-config.cfg \
        && su $USERNAME --login --command 'install-autonomous.sh configure \
            --config /tmp/install-autonomous-config.cfg $APPS' \
        && rm /tmp/install-autonomous-config.cfg"

rm -f -r "$WORKING_DIR"
