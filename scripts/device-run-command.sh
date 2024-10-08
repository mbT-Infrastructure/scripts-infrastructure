#!/usr/bin/env bash
set -e

COMMAND=""

# help message
for ARGUMENT in "$@"; do
    if [ "$ARGUMENT" == "-h" ] || [ "$ARGUMENT" == "--help" ]; then
        echo "usage: $(basename "$0") [ARGUMENT]"
        echo "Run a command on the local device."
        echo "ARGUMENT can be"
        echo "    --command COMMAND The command to execute."
        exit
    fi
done

# Check if run as root
if [[ "$(id --user)" != 0 ]]; then
    if [[ -n "$(which sudo)" ]];then
        sudo "$0" "$@"
        exit
    fi
    echo "Script must run as root"
    exit 1
fi

# check arguments
while [[ -n "$1" ]]; do
    if [[ "$1" == "--command" ]]; then
        shift
        COMMAND="$1"
    elif [[ "$1" == "--device" ]]; then
        shift
        echo "$(basename "$0"): \"--device $1\" is ignored" >&2
    else
        echo "Unknown argument: \"$1\""
        exit 1
    fi
    shift
done

eval "$COMMAND"
