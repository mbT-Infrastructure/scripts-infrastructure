#!/usr/bin/env bash
set -e

DEVICE=""
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# help message
for ARGUMENT in "$@"; do
    if [ "$ARGUMENT" == "-h" ] || [ "$ARGUMENT" == "--help" ]; then
        echo "usage: $(basename "$0") [ARGUMENT]"
        echo "Add certificate authorities."
        echo "ARGUMENT can be"
        echo "    --device DEVICE The device name."
        exit
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

echo "Add certificate authorities on device \"$DEVICE\"."

"${SCRIPT_DIR}/device-run-command.sh" --device "$DEVICE" --command \
    "curl --silent --location --output /usr/local/share/ca-certificates/mbt-ca-cert.crt \
    https://nas.madebytimo.de:5011/index.php/s/RaHmE2gJRYwkayp/download \
    && update-ca-certificates"
