#!/bin/sh
HELPER_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT="$HELPER_DIR"
if [ ! -f "$ROOT/scripts/install-syntax.mjs" ] && [ -f "$HELPER_DIR/../scripts/install-syntax.mjs" ]; then
  ROOT=$(CDPATH= cd -- "$HELPER_DIR/.." && pwd)
fi
cd "$ROOT" || exit 1

MAC_DMG_NAME="Syntax-Installer-0.1.2-universal.dmg"
MAC_DMG_URL="https://media.githubusercontent.com/media/Bendover002/SYNTAX_app-v1/main/$MAC_DMG_NAME"
MAC_DMG_SHA256="482d4d3cd31867ba2c39c8b70225cec35a0cc7ad28c1dc0916bd9a470b62d702"

is_lfs_pointer() {
  ARTIFACT="$1"
  [ -f "$ARTIFACT" ] || return 1
  SIZE=$(wc -c < "$ARTIFACT" | tr -d ' ')
  [ "$SIZE" -lt 1024 ] && grep -q "git-lfs.github.com/spec/v1" "$ARTIFACT"
}

verify_downloaded_dmg() {
  ARTIFACT="$1"
  if ! command -v shasum >/dev/null 2>&1; then
    echo "Cannot verify $MAC_DMG_NAME because shasum was not found."
    return 1
  fi

  ACTUAL_SHA=$(shasum -a 256 "$ARTIFACT" | awk '{print $1}')
  if [ "$ACTUAL_SHA" != "$MAC_DMG_SHA256" ]; then
    echo "Downloaded installer checksum did not match."
    echo "Expected: $MAC_DMG_SHA256"
    echo "Actual:   $ACTUAL_SHA"
    return 1
  fi

  if command -v hdiutil >/dev/null 2>&1; then
    hdiutil verify "$ARTIFACT" >/dev/null || return 1
  fi
}

download_real_dmg() {
  DEST="$HELPER_DIR/$MAC_DMG_NAME"
  TMP="$DEST.download"

  if ! command -v curl >/dev/null 2>&1; then
    echo "Cannot download $MAC_DMG_NAME because curl was not found."
    return 1
  fi

  echo "Downloading the real Syntax macOS installer..."
  echo "$MAC_DMG_URL"
  rm -f "$TMP"
  if ! curl -L --fail --progress-bar -o "$TMP" "$MAC_DMG_URL"; then
    rm -f "$TMP"
    echo "Download failed."
    return 1
  fi

  if ! verify_downloaded_dmg "$TMP"; then
    rm -f "$TMP"
    echo "Downloaded installer could not be verified."
    return 1
  fi

  mv "$TMP" "$DEST"
  echo "Downloaded and verified $MAC_DMG_NAME."
  LATEST_DMG="$DEST"
}

open_or_download_dmg() {
  LATEST_DMG=$(
    {
      ls -t "$HELPER_DIR"/Syntax-Installer-*.dmg 2>/dev/null
      ls -t "$ROOT"/Installers/Syntax-Installer-*.dmg 2>/dev/null
      ls -t "$ROOT"/build/Syntax-Installer-*.dmg 2>/dev/null
    } | head -n 1
  )

  if [ -z "$LATEST_DMG" ] || is_lfs_pointer "$LATEST_DMG"; then
    download_real_dmg || return 1
  fi

  open "$LATEST_DMG"
}

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
  if open_or_download_dmg; then
    if source_newer_than "$LATEST_DMG"; then
      echo "node was not found, and the newest Syntax installer is older than the app source."
      echo "Install Node.js, then run npm run package:mac so the macOS app includes the latest fixes."
      printf "Press Return to close."
      read REPLY
      exit 1
    fi
    exit 0
  fi

  echo "node was not found, and Syntax could not download the macOS installer."
  printf "Press Return to close."
  read REPLY
  exit 1
fi

if [ ! -f "$ROOT/scripts/install-syntax.mjs" ]; then
  if open_or_download_dmg; then
    exit 0
  fi

  echo "Syntax installer helper could not find scripts/install-syntax.mjs or download the macOS installer."
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
