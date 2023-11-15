#!/usr/bin/env bash
set -e

DEPENDENCIES=()
DEVICE=""
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
USER_GROUPS=""
USER_PASSWORD=""
USER_USERNAME=""

# help message
for ARGUMENT in "$@"; do
    if [ "$ARGUMENT" == "-h" ] || [ "$ARGUMENT" == "--help" ]; then
        echo "usage: $(basename "$0") [ARGUMENT]"
        echo "Run all upgrades from apt."
        echo "ARGUMENT can be"
        echo "    --groups GROUPS The groups for the user."
        echo "    --device DEVICE The device name."
        echo "    --password PASSWORD The login password for the user."
        echo "    --user USER The username of the user to add."
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
    elif [[ "$1" == "--groups" ]]; then
        shift
        USER_GROUPS="$1"
    elif [[ "$1" == "--password" ]]; then
        shift
        USER_PASSWORD="$1"
    elif [[ "$1" == "--user" ]]; then
        shift
        USER_USERNAME="$1"
    else
        echo "Unknown argument: \"$1\""
        exit 1
    fi
    shift
done

"${SCRIPT_DIR}/device-run-command.sh" --device "$DEVICE" --command \
    "(adduser $USER_USERNAME --disabled-password --gecos '' || true ) \
    && usermod --remove --groups $USER_GROUPS $USER_USERNAME \
    && usermod --append --groups $USER_GROUPS $USER_USERNAME"

if [[ -n "$USER_PASSWORD" ]]; then
    "${SCRIPT_DIR}/device-run-command.sh" --device "$DEVICE" --command \
        "yes '${USER_PASSWORD}' | passwd $USER_USERNAME"
fi
