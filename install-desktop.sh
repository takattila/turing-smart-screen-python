#!/bin/sh
# Generate and install the .desktop file with the correct install directory

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DESKTOP_FILE="$HOME/.local/share/applications/configure-turing-smart-screen.desktop"

mkdir -p "$HOME/.local/share/applications"

sed "s|{INSTALL_DIR}|$SCRIPT_DIR|g" "$SCRIPT_DIR/configure-turing-smart-screen.desktop" > "$DESKTOP_FILE"

echo "Installed: $DESKTOP_FILE"
