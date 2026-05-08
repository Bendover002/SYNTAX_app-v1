# SYNTAX_app-v1

## macOS Download

Easiest path:

1. Click GitHub's green **Code** button.
2. Click **Download ZIP**.
3. Unzip the downloaded file.
4. Double-click `Download Syntax Installer.html`.
5. Open the downloaded `Syntax-Installer-0.1.2-universal.dmg`.

The HTML file opens the real macOS installer download. It avoids GitHub's source-ZIP/LFS pointer problem, so customers do not accidentally open a fake 134-byte DMG.

Advanced fallback: double-click `Install Syntax.command`. The helper downloads, verifies, and opens the real DMG automatically.

You can also use this direct download link for the macOS installer:

https://media.githubusercontent.com/media/Bendover002/SYNTAX_app-v1/main/Syntax-Installer-0.1.2-universal.dmg

Expected file:

- Name: `Syntax-Installer-0.1.2-universal.dmg`
- Size: `187631008` bytes
- SHA-256: `482d4d3cd31867ba2c39c8b70225cec35a0cc7ad28c1dc0916bd9a470b62d702`

Do not download the installer from a `raw.githubusercontent.com` URL. That URL can return the Git LFS pointer text instead of the real DMG; the bad file is about 134 bytes and macOS will report it as corrupt.

GitHub's **Code > Download ZIP** source archive is only for the download helper files. It intentionally does not include the Git LFS installer binaries. Use `Download Syntax Installer.html` from that ZIP instead of looking for a DMG inside it.
