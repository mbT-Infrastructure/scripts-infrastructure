#!/usr/bin/env bash
set -e

DEVICE=""
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
CREDENTIALS_DIR=""
USERNAME=""
WORKING_DIR="${PWD}/.temp-$(basename "$0")"

# help message
for ARGUMENT in "$@"; do
    if [ "$ARGUMENT" == "-h" ] || [ "$ARGUMENT" == "--help" ]; then
        echo "usage: $(basename "$0") [ARGUMENT]"
        echo "Configure default ssh settings."
        echo "ARGUMENT can be"
        echo "    --credentials-dir Directory containing the credentials (ssh-config, ssh-key)."
        echo "    --device DEVICE The device name."
        echo "    --user USER The username of the user."
        exit
    fi
done

# check arguments
while [[ -n "$1" ]]; do
    if [[ "$1" == "--credentials-dir" ]]; then
        shift
        CREDENTIALS_DIR="$(realpath "$1")"
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
cd "$WORKING_DIR"

"${SCRIPT_DIR}/configure-apps.sh" --device "$DEVICE" --user "$USERNAME" --apps SSH --config \
    "https://raw.githubusercontent.com/mbT-Infrastructure/template-config-files/main/debian/ssh/\
ssh.cfg"

"${SCRIPT_DIR}/device-run-command.sh" --device "$DEVICE" --command \
    "rm -f -r '/home/${USERNAME}/credentials/ssh' \
    && mkdir --parents '/home/${USERNAME}/credentials/ssh' \
    && chown '${USERNAME}:${USERNAME}' '/home/${USERNAME}/credentials' \
        '/home/${USERNAME}/credentials/ssh' \
    && chmod 0700 '/home/${USERNAME}/credentials/ssh'"

if [[ -n "$CREDENTIALS_DIR" ]]; then
    if [[ -f "${CREDENTIALS_DIR}/ssh/ssh-config" ]]; then
        cp "${CREDENTIALS_DIR}/ssh/ssh-config" ssh-config
        "${SCRIPT_DIR}/device-upload-file.sh" --device "$DEVICE" \
        --file ssh-config --target "/home/${USERNAME}/credentials/ssh"
        rm ssh-config
        "${SCRIPT_DIR}/device-run-command.sh" --device "$DEVICE" --command \
            "chown '${USERNAME}:${USERNAME}' '/home/${USERNAME}/credentials/ssh/ssh-config' \
            && chmod 0600 '/home/${USERNAME}/credentials/ssh/ssh-config'"
    fi

    if [[ -f "${CREDENTIALS_DIR}/ssh/ssh-key" ]]; then
        cp "${CREDENTIALS_DIR}/ssh/ssh-key" ssh-key
        "${SCRIPT_DIR}/device-upload-file.sh" --device "$DEVICE" \
        --file ssh-key --target "/home/${USERNAME}/credentials/ssh"
        rm ssh-key
        "${SCRIPT_DIR}/device-run-command.sh" --device "$DEVICE" --command \
            "chown '${USERNAME}:${USERNAME}' '/home/${USERNAME}/credentials/ssh/ssh-key' \
            && chmod 0600 '/home/${USERNAME}/credentials/ssh/ssh-key' \
            && ssh-keygen -f '/home/${USERNAME}/credentials/ssh/ssh-key' -y \
            > '/home/${USERNAME}/credentials/ssh/ssh-key.pub' \
            && chown '${USERNAME}:${USERNAME}' '/home/${USERNAME}/credentials/ssh/ssh-key.pub' \
            && chmod 0600 '/home/${USERNAME}/credentials/ssh/ssh-key.pub'"
    fi
fi

rm -f -r "$WORKING_DIR"
