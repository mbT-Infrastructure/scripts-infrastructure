#!/usr/bin/env bash
set -e

DEVICE=""
FILE=""
TARGET=""

# help message
for ARGUMENT in "$@"; do
    if [ "$ARGUMENT" == "-h" ] || [ "$ARGUMENT" == "--help" ]; then
        echo "usage: $(basename "$0") [ARGUMENT] COMMAND"
        echo "Upload a file to the local device."
        echo "ARGUMENT can be"
        echo "    --file FILE The path of the file to upload."
        echo "    --target TARGET The target folder path to upload the file to."
        exit
    fi
done

# check arguments
while [[ -n "$1" ]]; do
    if [[ "$1" == "--device" ]]; then
        shift
        DEVICE="$1"
    elif [[ "$1" == "--file" ]]; then
        shift
        FILE="$1"
    elif [[ "$1" == "--target" ]]; then
        shift
        TARGET="$1"
    else
        echo "Unknown argument: \"$1\""
        exit 1
    fi
    shift
done

if [[ -f "$FILE" ]]; then
    FILE="$(realpath "$FILE")"
else
    echo "File \"${FILE}\" not found"
fi

if [[ -z "$DEVICE" ]] || [[ "$DEVICE" == localhost ]]; then
    if [[ "$(id --user)" != 0 ]]; then
        sudo cp "$FILE" "$TARGET"
    else
        cp "$FILE" "$TARGET"
    fi
else
    scp "$FILE" "${DEVICE}:$TARGET"
fi
