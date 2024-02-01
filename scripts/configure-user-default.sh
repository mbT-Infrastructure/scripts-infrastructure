#!/usr/bin/env bash
set -e

DEPENDENCIES=()
DEVICE=""
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
SUPERUSER=false
USER_PASSWORD=""
USER_USERNAME="user"

# help message
for ARGUMENT in "$@"; do
    if [ "$ARGUMENT" == "-h" ] || [ "$ARGUMENT" == "--help" ]; then
        echo "usage: $(basename "$0") [ARGUMENT]"
        echo "Run Scripts to configure a PC-Debian for only one user."
        echo "ARGUMENT can be"
        echo "    --device DEVICE The device name."
        echo "    --password PASSWORD The password of the user."
        echo "        If empty, the user has to be already created or no password is set."
        echo "    --superuser User with administrative privileges."
        echo "    --user USER The username of the user, default: \"${USER_USERNAME}\""
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
    elif [[ "$1" == "--password" ]]; then
        shift
        USER_PASSWORD="$1"
    elif [[ "$1" == "--superuser" ]]; then
        SUPERUSER=true
    elif [[ "$1" == "--user" ]]; then
        shift
        USER_USERNAME="$1"
    else
        echo "Unknown argument: \"$1\""
        exit 1
    fi
    shift
done


USER_GROUPS="audio,bluetooth,dip,netdev,plugdev,scanner,video"
if [[ -n "$SUPERUSER" ]]; then
    USER_GROUPS+=",docker,sudo"
fi
ADDITIONAL_ARGUMENTS=()
if [[ -n "$USER_PASSWORD" ]]; then
    ADDITIONAL_ARGUMENTS+=(--password "$USER_PASSWORD")
fi
"${SCRIPT_DIR}/configure-user.sh" --device "$DEVICE" --groups "$USER_GROUPS" \
    --user "$USER_USERNAME" "${ADDITIONAL_ARGUMENTS[@]}"

"${SCRIPT_DIR}/configure-autostart.sh" --device "$DEVICE" --user "$USER_USERNAME"
"${SCRIPT_DIR}/configure-cinnamon.sh" --device "$DEVICE" --user "$USER_USERNAME"
"${SCRIPT_DIR}/configure-copyq.sh" --device "$DEVICE" --user "$USER_USERNAME"
"${SCRIPT_DIR}/configure-default-applications.sh" --device "$DEVICE" --user "$USER_USERNAME"
"${SCRIPT_DIR}/configure-desktop-entries.sh" --device "$DEVICE" --user "$USER_USERNAME"
"${SCRIPT_DIR}/configure-git.sh" --device "$DEVICE" --user "$USER_USERNAME"
"${SCRIPT_DIR}/configure-scanner.sh" --device "$DEVICE" --user "$USER_USERNAME"
"${SCRIPT_DIR}/configure-tor-browser.sh" --device "$DEVICE" --user "$USER_USERNAME"
"${SCRIPT_DIR}/configure-vlc.sh" --device "$DEVICE" --user "$USER_USERNAME"
"${SCRIPT_DIR}/configure-vs-code.sh" --device "$DEVICE" --user "$USER_USERNAME"
