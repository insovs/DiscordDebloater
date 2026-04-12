<div align="center">
<img width="1365" height="520" alt="image" src="https://github.com/user-attachments/assets/fe605325-18c2-43f4-ba58-430fe891b6aa" />
  
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue?style=flat-square&logo=powershell&logoColor=white)](https://github.com/PowerShell/PowerShell)
[![Windows](https://img.shields.io/badge/Windows-10%2F11-0078D4?style=flat-square&logo=windows&logoColor=white)](https://www.microsoft.com/windows)
[![Version](https://img.shields.io/badge/Version-1.1-6b7280?style=flat-square)](#)
[![Discord](https://img.shields.io/badge/Support-Discord-5865F2?logo=discord&logoColor=white)](https://discord.com/invite/fayeECjdtb)
[![Preview](https://img.shields.io/badge/Video-Preview-FF0000?logo=youtube&logoColor=white)](https://youtu.be/9zvIpOmYuK8)

---

<img width="926" height="705" alt="image" src="https://github.com/user-attachments/assets/84787516-c0c6-457a-b0e9-30bd9445888d" />

</div>

---

## Overview

Discord ships with a significant amount of overhead most users never need — multiple language packs, noise suppression modules, auto-updater binaries, crash reporters, telemetry trackers, and GPU cache. This tool provides a clean GUI to selectively remove or disable these components without touching anything critical to Discord's core functionality.

All operations run in isolated PowerShell runspaces with live progress feedback. Nothing is removed silently.

---

## Features

### Debloat

Strips unused components from your Discord installation directory.

- Removes old version folders (`app-x.x.x`) and keeps only the latest
- Deletes unused native modules while preserving the core runtime
- Removes all language packs except the ones you select (English, French, or both)
- Optionally removes the Krisp noise suppression module
- Optionally removes Game SDK DLLs (`discord_game_sdk_*.dll`)
- Optionally removes Game Presence / RPC support
- Removes junk files: `.sig` signatures, Vulkan/SwiftShader/d3dcompiler DLLs, unused Chromium assets
- Removes the auto-updater binaries (`Update.exe`, Squirrel, RELEASES)
- Disables Discord autostart via registry Run keys and scheduled tasks
- Disables Fullscreen Optimization (FSO) for the Discord executable

### Optimize Settings

Writes a performance-focused `settings.json` to your Discord AppData folder.

| Setting | Value | Effect |
|---|---|---|
| `enableHardwareAcceleration` | `false` | Reduces GPU overhead |
| `SKIP_HOST_UPDATE` | `true` | Prevents update checks on every launch |
| `DEVELOPER_MODE` | `true` | Exposes extra tooling |
| `MINIMIZE_TO_TRAY` | `true` | Hides to tray on close |
| `debugLogging` | `false` | Stops writing verbose logs to disk |
| `IS_MAXIMIZED` | `true` | Starts maximized |
| `START_MINIMIZED` | `false` | Launches in foreground |

### Clean Cache

Clears accumulated runtime data from Discord's AppData folder.

Targets: `Cache`, `Code Cache`, `GPUCache`, `ShaderCache`, `VideoDecodeStats`, `Cookies`, `Web Data`, `Databases`, `Session Storage`, `logs`, `Crashpad`, `debug`, `sentry`, `WidevineCdm`, `MediaFoundationWidevineCdm`, `blob_storage`, `CacheStorage`, `shared_proto_db`, and more.

Optional: remove `Local Storage` (signs you out, but frees additional space).

---

## Advanced Options

Accessible via the **Advanced** button in the Debloat panel.

| Option | Default | Notes |
|---|---|---|
| Create backup before debloating | Off | Copies the full Discord folder to your Desktop |
| Remove Krisp | Off | Only disable if you use a separate noise cancellation solution |
| Remove Game SDK DLLs | On | Safe for most users |
| Remove Game Presence / RPC | Off | Required by some games (e.g. FiveM) for account linking |
| Remove auto-updater | On | Replaces the Desktop shortcut with a direct launcher |
| Disable autostart | On | Removes registry Run keys and scheduled tasks |
| Disable FSO | On | Prevents Windows from overriding exclusive fullscreen mode |
| Remove junk files | On | `.sig`, SwiftShader, Vulkan, d3dcompiler, unused Chromium paks |

---

## Usage

Download `DiscordDebloatTool.ps1`, then **right-click** it → **Run with PowerShell**

The script will automatically request administrator privileges.

> [!CAUTION]
> If PowerShell scripts are blocked on your system, enable execution first:
> ```powershell
> Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
> ```
> Or use **[EnablePowerShellScript](https://github.com/insovs/EnablePowerShellScript)** for a one-click solution.

---

## Notes

- **After debloating**, create a new shortcut pointing directly to `Discord.exe` inside the active version folder. The auto-updater shortcut will no longer work if you removed `Update.exe`. A shortcut named `Discord Debloated.lnk` is automatically created on your Desktop.
- **After cleaning cache**, some Discord UI preferences (font size, theme, etc.) may reset. Your account session will be preserved unless you opted into removing Local Storage.
- **Game Presence / RPC**: removing this module disables rich presence broadcasting and may prevent joining servers that require Discord account linking (e.g. FiveM, some game launchers).
- **Autostart**: the tool removes both registry `Run` keys and any Discord scheduled tasks. You can re-enable autostart from Discord's settings at any time.
- **Backup**: if enabled, a full copy of the Discord installation folder is saved to your Desktop before any file is deleted.

---

## License

For personal use only. Redistribution is prohibited.

---

<div align="center">

`github.com/insovs/discord-debloat`

</div>
