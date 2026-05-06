#!/bin/sh
HELPER_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT="$HELPER_DIR"
if [ ! -f "$ROOT/scripts/install-syntax.mjs" ] && [ -f "$HELPER_DIR/../scripts/install-syntax.mjs" ]; then
  ROOT=$(CDPATH= cd -- "$HELPER_DIR/.." && pwd)
fi
cd "$ROOT" || exit 1

source_newer_than() {
  ARTIFACT="$1"
  for ITEM in     "$ROOT/package.json"     "$ROOT/package-lock.json"     "$ROOT/index.html"     "$ROOT/src"     "$ROOT/scripts"     "$ROOT/test"     "$ROOT/Logos"     "$ROOT/Install Syntax.command"
  do
    if [ -e "$ITEM" ] && find "$ITEM" -newer "$ARTIFACT" -print -quit | grep -q .; then
      return 0
    fi
  done
  return 1
}

if ! command -v node >/dev/null 2>&1; then
  LATEST_DMG=$(
    {
      ls -t "$HELPER_DIR"/Syntax-Installer-*.dmg 2>/dev/null
      ls -t "$ROOT"/Installers/Syntax-Installer-*.dmg 2>/dev/null
      ls -t "$ROOT"/build/Syntax-Installer-*.dmg 2>/dev/null
    } | head -n 1
  )
  if [ -n "$LATEST_DMG" ]; then
    if source_newer_than "$LATEST_DMG"; then
      echo "node was not found, and the newest Syntax installer is older than the app source."
      echo "Install Node.js, then run npm run package:mac so the macOS app includes the latest fixes."
      printf "Press Return to close."
      read REPLY
      exit 1
    fi
    open "$LATEST_DMG"
    exit 0
  fi

  echo "node was not found. Install Node.js or run npm run package:mac from a developer terminal."
  printf "Press Return to close."
  read REPLY
  exit 1
fi

if [ ! -f "$ROOT/scripts/install-syntax.mjs" ]; then
  LATEST_DMG=$(
    {
      ls -t "$HELPER_DIR"/Syntax-Installer-*.dmg 2>/dev/null
      ls -t "$ROOT"/Installers/Syntax-Installer-*.dmg 2>/dev/null
      ls -t "$ROOT"/build/Syntax-Installer-*.dmg 2>/dev/null
    } | head -n 1
  )
  if [ -n "$LATEST_DMG" ]; then
    open "$LATEST_DMG"
    exit 0
  fi

  echo "Syntax installer helper could not find scripts/install-syntax.mjs."
  printf "Press Return to close."
  read REPLY
  exit 1
fi

node "$ROOT/scripts/install-syntax.mjs"
STATUS=$?
if [ "$STATUS" -ne 0 ]; then
  printf "Press Return to close."
  read REPLY
fi

exit "$STATUS"
