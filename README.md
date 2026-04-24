<div align="center">
  
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue?style=flat-square&logo=powershell&logoColor=white)](https://github.com/PowerShell/PowerShell)
[![Windows](https://img.shields.io/badge/Windows-10%2F11-0078D4?style=flat-square&logo=windows&logoColor=white)](https://www.microsoft.com/windows)
[![Version](https://img.shields.io/badge/Version-1.1-6b7280?style=flat-square)](#)
[![Discord](https://img.shields.io/badge/Support-Discord-5865F2?logo=discord&logoColor=white)](https://discord.com/invite/fayeECjdtb)
[![Preview](https://img.shields.io/badge/Video-Preview-FF0000?logo=youtube&logoColor=white)](https://youtu.be/9zvIpOmYuK8)
  
<img width="1448" height="1086" alt="DiscordBanner" src="https://github.com/user-attachments/assets/a2bab54a-5f09-47e1-bc05-6909caadd7c9" />

---
</div>

## 🚀 Overview

Discord ships with a significant amount of overhead that most users never need — including multiple language packs, noise suppression modules, auto-updater binaries, crash reporters, telemetry trackers, and GPU cache. This tool provides a clean GUI to selectively remove or disable these components without affecting anything critical to Discord's core functionality.

It is designed so that Discord consumes only what is strictly necessary, reducing its overall resource usage and making it significantly lighter.

<details>
<summary><b>👁️ Show Preview Tool</b></summary>
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/ad039020-d39d-4256-8deb-d592a52a5442" />


</details>

---

## 📥 Usage

Download `DiscordDebloatTool.ps1`, then **right-click** it → **Run with PowerShell**

> [!CAUTION]
> If PowerShell scripts are blocked on your system, enable execution first:
> ```powershell
> Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
> ```
> Or use **[EnablePowerShellScript](https://github.com/insovs/EnablePowerShellScript)** for a one-click solution.

---

## ⚡ Features

### Debloat Section

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

### Optimize Settings Section

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

### Clean Cache Section

Clears accumulated runtime data from Discord's AppData folder.

Targets: `Cache`, `Code Cache`, `GPUCache`, `ShaderCache`, `VideoDecodeStats`, `Cookies`, `Web Data`, `Databases`, `Session Storage`, `logs`, `Crashpad`, `debug`, `sentry`, `WidevineCdm`, `MediaFoundationWidevineCdm`, `blob_storage`, `CacheStorage`, `shared_proto_db`, and more.

Optional: remove `Local Storage` (signs you out, but frees additional space).

---

## 🛠️ Advanced Options
Accessible via the **Advanced** button in the Debloat panel. Each option can be individually toggled — only apply what you need.

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

> [!CAUTION]
> **Game Presence / RPC**: removing this module disables rich presence broadcasting and may prevent joining servers that require Discord account linking (e.g. FiveM, some game launchers). Consider enabling the **backup option** before proceeding.

---

## 📌 Notes
- **Backup**: if enabled, a full copy of the Discord installation folder is saved to your Desktop before any file is deleted.
- **Two versions**: by creating a backup, you can run both a debloated and an original version of Discord.
- **After debloating:** a `Discord Debloated.lnk` shortcut is auto-created on your Desktop pointing directly to `Discord.exe` — bypassing update checks on every launch.
- **After cleaning cache**, some Discord UI preferences (font size, theme, etc.) may reset. Your account session will be preserved unless you opted into removing Local Storage.

---

<div align="center">

`(https://github.com/insovs/Discord-Optimization)`

</div>
