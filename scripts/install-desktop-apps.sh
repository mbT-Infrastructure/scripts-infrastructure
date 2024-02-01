#!/usr/bin/env bash
set -e

DEVICE=""
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# help message
for ARGUMENT in "$@"; do
    if [ "$ARGUMENT" == "-h" ] || [ "$ARGUMENT" == "--help" ]; then
        echo "usage: $(basename "$0") [ARGUMENT]"
        echo "Install apps for desktop."
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

"${SCRIPT_DIR}/install-apps.sh" --device "$DEVICE" --apps \
    "Anki AuthenticationModules Backgrounds Chromium CopyQ DBeaver DesktopBasics Discord FFmpeg \
    Fileorganizer Firefox Firmware FreeCAD GoogleChrome IntellijIdea Java Krita LibreOffice \
    Linphone MetadataEditors MintThemes NetworkManager NodeJs OCRTools PDFsam PortfolioPerformance \
    Printer Python RemoteDesktopClient Scanner ScriptsAdvanced ScriptsDesktop ScriptsDevelopment \
    Shotcut Signal SlickGreeter Sudo UltimakerCura VLC VSCode Xournal++"
