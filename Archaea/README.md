# Archaea

**Archaea** is a collection of Windows batch scripts designed to reset and configure PCs (such as those used in a dojo or lab environment) to a clean, functional, and standardized state.

The scripts handle disk cleanup, software installation, DNS configuration, and other essential tasks to ensure machines remain consistent and usable across sessions or users.

---

## 📁 Included Scripts

| Script             | Description |
|--------------------|-------------|
| `awake.bat`        | Copies itself and all local installers to `C:\Users\%USERNAME%\Downloads\Archaea` on the host machine for portability. |
| `delete.bat`       | Deletes all non-critical files from the PC to free up disk space while safely skipping system-critical components (e.g., Explorer, CMD, Settings). |
| `setup.bat`        | Installs and/or updates a predefined set of essential applications using `winget`, and sets DNS to a local AdGuard Home instance. |
| `start.bat`        | Main entry point: runs `delete.bat` followed by `setup.bat`, then cleans up the Archaea directory if possible. |
| `winget.bat`       | Installs `winget` (Windows Package Manager) for systems where it is not yet available. |
| `archaea_allinone.bat` | Combines all of the above into a single runnable script for convenience. |

---

## 🔧 Features

- Automated cleanup of unnecessary files and folders.
- One-click installation and updating of required software including:
  - Unity Hub + Unity Editor(s)
  - Blender
  - Brave
  - Minecraft (Java + Education)
  - Scratch 3
  - Roblox Player & Studio
  - MCreator
  - GitHub Desktop
  - Visual Studio 2022 Community Edition
  - UniGetUI
  - SuperCode (custom installer)
- DNS configuration to `192.168.1.240` (AdGuard Home instance).
- Designed for use in educational or lab-style environments.

---

## 🛠️ Requirements

- Windows 10 or 11
- Administrator privileges
- Internet connection for software installation
- `winget` (Windows Package Manager) — can be installed using `winget.bat`

---

## 🚀 Usage

1. **Initial Setup:**
   - Copy the Archaea folder to the target PC or run `awake.bat` from a prepared USB/network location.

2. **Run the Tool:**
   - Execute `start.bat` as Administrator to:
     - Wipe unnecessary files
     - Install/update essential software
     - Apply DNS settings

3. **For systems missing winget:**
   - Run `winget.bat` before any other scripts.

---

## ✅ TODO

- [ ] Add support for running Archaea entirely from a network share.
- [ ] Implement command-line flags for custom behavior and default presets.

---

## 📎 Notes

- All Unity installations are managed via Unity Hub CLI.
- DNS settings apply to interfaces named `WiFi` or `Wi-Fi`.
- `delete.bat` is designed to skip critical system files to prevent bricking the PC, but caution is still advised when using it outside test environments (e.g., VMs).

---

## 🔒 Disclaimer

This script is powerful and potentially destructive if misused. Always test in a **virtual machine** or non-critical environment before deploying to real hardware.

---
