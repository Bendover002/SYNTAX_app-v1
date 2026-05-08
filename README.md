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

If macOS still blocks the first launch, use `Backup Install.command` as a backup helper. Download it, right-click it, choose `Open`, and follow the prompts.

## Notes

- This installer is for Apple Silicon Macs (`arm64`).
- Keep the DMG if you want to reinstall later.
