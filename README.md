# Syntax macOS Installer

This repository contains the macOS installer for Syntax.

## Install

1. Download `Syntax-Installer-0.1.2-arm64.dmg`.
2. Open the DMG.
3. Drag `Syntax.app` into the `Applications` folder.
4. Eject the DMG.
5. Open `Applications`, right-click `Syntax`, then choose `Open`.
6. In the macOS warning dialog, choose `Open` again.

The right-click `Open` step is required because this build is unsigned and not notarized. You should only need to do it the first time you launch this copy of Syntax.

## Backup Helper

Most users should not need `Backup Install.command`. It is only a fallback for cases where right-clicking `Syntax.app` does not work.

Because this helper is also unsigned, double-clicking it can show the same Apple malware verification warning. If you need to use it:

1. Download `Backup Install.command`.
2. Open `Downloads`.
3. Right-click `Backup Install.command`, then choose `Open`.
4. If macOS still blocks it, open `System Settings` > `Privacy & Security`, scroll down, and choose `Open Anyway`.
5. Follow the prompts.

If you are not comfortable running the backup helper, skip it and use `System Settings` > `Privacy & Security` > `Open Anyway` for `Syntax.app` instead.

Apple shows these warnings because this build is not signed or notarized with an Apple Developer account. The warning is expected for this private installer.

## Notes

- This installer is for Apple Silicon Macs (`arm64`).
- Keep the DMG if you want to reinstall later.
