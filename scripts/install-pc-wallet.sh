#!/usr/bin/env bash
set -e

DEPENDENCIES=()
DEVICE=""
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# help message
for ARGUMENT in "$@"; do
    if [ "$ARGUMENT" == "-h" ] || [ "$ARGUMENT" == "--help" ]; then
        echo "usage: $(basename "$0") [ARGUMENT]"
        echo "Run Scripts to install a PC-Wallet."
        echo "ARGUMENT can be"
        echo "    --device DEVICE The device name."
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
    else
        echo "Unknown argument: \"$1\""
        exit 1
    fi
    shift
done

"${SCRIPT_DIR}/install-base-debian.sh" --device "$DEVICE"
"${SCRIPT_DIR}/install-locales.sh" --device "$DEVICE"
"${SCRIPT_DIR}/install-desktop-environment.sh" --device "$DEVICE"
"${SCRIPT_DIR}/install-apps.sh" --device "$DEVICE" --apps \
    "Electrum Htop MoneroGui NTPClient VerusDesktop"
"${SCRIPT_DIR}/configure-user.sh" --device "$DEVICE" --groups plugdev --user user
"${SCRIPT_DIR}/configure-cinnamon.sh" --device "$DEVICE" --user user
"${SCRIPT_DIR}/configure-default-applications.sh" --device "$DEVICE" --user user
"${SCRIPT_DIR}/device-run-command.sh" --device "$DEVICE" --command  \
    "echo 'autologin-user=user' >> /etc/lightdm/lightdm.conf"
"${SCRIPT_DIR}/install-network.sh" --device "$DEVICE"
"${SCRIPT_DIR}/device-run-command.sh" --device "$DEVICE" --command  \
    "passwd --delete user && passwd --lock root"
"${SCRIPT_DIR}/device-reboot.sh" --device "$DEVICE"
echo "Disable meshagent service. Remote access is still available till next reboot."
"${SCRIPT_DIR}/device-run-command.sh" --device "$DEVICE" --command "systemctl disable meshagent"
