#!/bin/bash
set -euo pipefail

APP_NAME="Syntax.app"
APP_PATH="/Applications/$APP_NAME"

show_message() {
  /usr/bin/osascript -e "display dialog \"$1\" buttons {\"OK\"} default button \"OK\" with title \"Syntax Backup Install\""
}

# Find the DMG — try mounted volume first, then the DMG file itself
DMG_PATH=""
if [ -d "/Volumes/Syntax" ]; then
  DMG_PATH="/Volumes/Syntax"
elif [ -f "$(cd "$(dirname "$0")" && pwd)/Syntax-Installer-0.1.2-arm64.dmg" ]; then
  DMG_PATH="$(cd "$(dirname "$0")" && pwd)/Syntax-Installer-0.1.2-arm64.dmg"
fi

if [ -z "$DMG_PATH" ]; then
  show_message "Could not find the Syntax DMG. Download it again or drag Syntax.app to Applications manually."
  exit 1
fi

# Mount DMG if it's not already mounted
if [ -f "$DMG_PATH" ]; then
  MOUNT_POINT=$(/usr/bin/hdiutil attach -nobrowse "$DMG_PATH" 2>/dev/null | tail -1 | awk '{print $NF}')
  if [ -z "$MOUNT_POINT" ] || [ ! -d "$MOUNT_POINT" ]; then
    show_message "Failed to mount the Syntax DMG."
    exit 1
  fi
  DMG_PATH="$MOUNT_POINT"
fi

if [ ! -d "$DMG_PATH/$APP_NAME" ]; then
  show_message "Syntax.app was not found in the DMG. The DMG may be damaged."
  exit 1
fi

# Remove existing installation if present
if [ -d "$APP_PATH" ]; then
  /bin/rm -rf "$APP_PATH"
fi

# Copy from DMG to Applications
/bin/cp -R "$DMG_PATH/$APP_NAME" "/Applications/"

# Remove quarantine on the fresh copy
/usr/bin/xattr -dr com.apple.quarantine "$APP_PATH" 2>/dev/null || true

# Eject DMG if we mounted it
if [ -f "$DMG_PATH" ] || [ -n "$MOUNT_POINT" ]; then
  /usr/bin/hdiutil detach "$DMG_PATH" -quiet 2>/dev/null || true
fi

show_message "Syntax has been re-installed from the DMG. You can now open it from Applications."
/usr/bin/open "$APP_PATH"
exit 0