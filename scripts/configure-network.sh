#!/usr/bin/env bash
set -e

CREDENTIALS_DIR=""
DEVICE=""
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
WORKING_DIR="${PWD}/.temp-$(basename "$0")"

# help message
for ARGUMENT in "$@"; do
    if [ "$ARGUMENT" == "-h" ] || [ "$ARGUMENT" == "--help" ]; then
        echo "usage: $(basename "$0") [ARGUMENT]"
        echo "Configure network settings."
        echo "ARGUMENT can be"
        echo "    --credentials-dir Directory containing the credentials" \
            "(network-manager.cfg, network)."
        echo "    --device DEVICE The device name."
        echo "    --user USER The username of the user."
        exit
    fi
done

# check arguments
while [[ -n "$1" ]]; do
    if [[ "$1" == "--credentials-dir" ]]; then
        shift
        CREDENTIALS_DIR="$1"
    elif [[ "$1" == "--device" ]]; then
        shift
        DEVICE="$1"
    else
        echo "Unknown argument: \"$1\""
        exit 1
    fi
    shift
done

if [[ -z "$SSH_CREDENTIALS_DIR" ]]; then
    echo "Credentials-dir is required!"
fi

if [[ -e "$WORKING_DIR" ]]; then
    echo "\"${WORKING_DIR}\" exists already. Removing in 10 seconds."
    sleep 10
    rm -f -r "$WORKING_DIR"
fi
mkdir "$WORKING_DIR"
cd "$WORKING_DIR"

if [[ -d "${CREDENTIALS_DIR}/network" ]]; then
    compress.sh "${CREDENTIALS_DIR}/network"
    "${SCRIPT_DIR}/device-upload-file.sh" --device "$DEVICE" \
    --file ssh-config --target "/home/root/credentials/network.tar.zst"
    rm network.tar.zst
    "${SCRIPT_DIR}/device-run-command.sh" --device "$DEVICE" --command \
        "cd /home/root/credentials \
        && compress.sh --decompress network.tar.zst \
        && rm network.tar.zst \
        && chown --recursive 'root:root' '/home/root/credentials/network'"
fi

rm -f -r "$WORKING_DIR"

"${SCRIPT_DIR}/configure-app.sh" --device "$DEVICE" --user root --app NetworkManager --config \
    "${CREDENTIALS_DIR}/network-manager.cfg"