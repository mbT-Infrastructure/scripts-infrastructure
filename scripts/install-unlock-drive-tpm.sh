#!/usr/bin/env bash
set -e

DEVICE=""
DRIVE_PASSWORD=""
PCR_IDS="0,1,7"
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# help message
for ARGUMENT in "$@"; do
    if [ "$ARGUMENT" == "-h" ] || [ "$ARGUMENT" == "--help" ]; then
        echo "usage: $(basename "$0") [ARGUMENT]"
        echo "Unlock boot drive automatically with clevis and tpm2."
        echo "ARGUMENT can be"
        echo "    --device DEVICE The device name."
        echo "    --password PASSWORD The password of the drive."
        exit
    fi
done

# check arguments
while [[ -n "$1" ]]; do
    if [[ "$1" == "--device" ]]; then
        shift
        DEVICE="$1"
    elif [[ "$1" == "--password" ]]; then
        shift
        DRIVE_PASSWORD="$1"
    elif [[ "$1" == "--pcr-ids" ]]; then
        shift
        PCR_IDS="$1"
    else
        echo "Unknown argument: \"$1\""
        exit 1
    fi
    shift
done

if [[ -z "$DRIVE_PASSWORD" ]]; then
    echo "Please set the drive password."
    exit 1
fi

echo "Setup unlocking of boot drive with tpm on device \"$DEVICE\"."

"${SCRIPT_DIR}/device-run-command.sh" --device "$DEVICE" --command \
    "export DEBIAN_FRONTEND=noninteractive && apt update -qq \
    && apt install -y -qq clevis clevis-initramfs clevis-luks clevis-tpm2"
BOOT_LUKS_OUTPUT="$("${SCRIPT_DIR}/device-run-command.sh" --device "$DEVICE" \
    --command \
    "lsblk --output NAME,FSTYPE --paths --noheadings --list")"
echo "$BOOT_LUKS_OUTPUT"
BOOT_LUKS="$(echo "$BOOT_LUKS_OUTPUT" | \
    grep crypto_LUKS | \
    sed 's|^\s*\(/dev/[^ ]*\) .*|\1|')"
if [[ -z "$BOOT_LUKS" ]]; then
    echo "No compatible drive found."
    exit 1
fi
"${SCRIPT_DIR}/device-run-command.sh" --device "$DEVICE" --command \
    "echo '$DRIVE_PASSWORD' | \
    clevis luks bind -k - \
    -d '$BOOT_LUKS' tpm2 '{\"pcr_bank\":\"sha256\",\"pcr_ids\":\"${PCR_IDS}\"}'"
