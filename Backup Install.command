#!/bin/bash
set -euo pipefail

APP_PATH="/Applications/Syntax.app"

show_message() {
  /usr/bin/osascript -e "display dialog \"$1\" buttons {\"OK\"} default button \"OK\" with title \"Syntax First Launch\""
}

has_developer_id_signature() {
  local details
  details="$(/usr/bin/codesign -dv --verbose=4 "$APP_PATH" 2>&1 || true)"
  [[ "$details" == *"Authority=Developer ID Application"* ]] &&
    [[ "$details" != *"Signature=adhoc"* ]] &&
    [[ "$details" != *"TeamIdentifier=not set"* ]]
}

repair_syntax() {
  /usr/bin/xattr -dr com.apple.quarantine "$APP_PATH" 2>/dev/null || true
  /usr/bin/xattr -dr com.apple.provenance "$APP_PATH" 2>/dev/null || true

  if ! has_developer_id_signature; then
    /usr/bin/codesign --force --deep --sign - "$APP_PATH"
  fi

  /usr/bin/codesign --verify --deep --strict --verbose=2 "$APP_PATH" >/dev/null
}

repair_syntax_as_admin() {
  local admin_script
  admin_script='
APP_PATH="/Applications/Syntax.app"
/usr/bin/xattr -dr com.apple.quarantine "$APP_PATH" 2>/dev/null || true
/usr/bin/xattr -dr com.apple.provenance "$APP_PATH" 2>/dev/null || true
DETAILS="$(/usr/bin/codesign -dv --verbose=4 "$APP_PATH" 2>&1 || true)"
case "$DETAILS" in
  *"Authority=Developer ID Application"*)
    ;;
  *)
    /usr/bin/codesign --force --deep --sign - "$APP_PATH"
    ;;
esac
/usr/bin/codesign --verify --deep --strict --verbose=2 "$APP_PATH" >/dev/null
'

  /usr/bin/osascript - "$admin_script" <<'APPLESCRIPT'
on run argv
  do shell script item 1 of argv with administrator privileges
end run
APPLESCRIPT
}

if [[ ! -d "$APP_PATH" ]]; then
  show_message "Syntax.app was not found in Applications. Drag Syntax.app to Applications first, then run this helper again."
  exit 1
fi

if repair_syntax; then
  show_message "Syntax is ready to open from Applications."
  /usr/bin/open "$APP_PATH"
  exit 0
fi

if repair_syntax_as_admin; then
  show_message "Syntax is ready to open from Applications."
  /usr/bin/open "$APP_PATH"
  exit 0
fi

show_message "Syntax could not be repaired automatically. Right-click Syntax.app in Applications and choose Open, or use System Settings > Privacy & Security > Open Anyway."
exit 1
