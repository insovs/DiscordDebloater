<div align="center">
  
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue?style=flat-square&logo=powershell&logoColor=white)](https://github.com/PowerShell/PowerShell)
[![Windows](https://img.shields.io/badge/Windows-10%2F11-0078D4?style=flat-square&logo=windows&logoColor=white)](https://www.microsoft.com/windows)
[![Version](https://img.shields.io/badge/Version-1.1-6b7280?style=flat-square)](#)
[![Discord](https://img.shields.io/badge/Support-Discord-5865F2?logo=discord&logoColor=white)](https://discord.com/invite/fayeECjdtb)
[![Preview](https://img.shields.io/badge/Video-Preview-FF0000?logo=youtube&logoColor=white)](https://youtu.be/9zvIpOmYuK8)

<img width="1536" height="1024" alt="image" src="https://github.com/user-attachments/assets/e691b5cc-331f-4a8a-aa47-1f44fa3b51b9" />

<img src="https://github.com/user-attachments/assets/ca18be27-672c-47d7-a083-6c8f252b2d44" alt="GIF" width="1080">

---
</div>

## 🚀 Overview

**Discord ships with a significant amount of overhead that most users never need — including multiple language packs, noise suppression modules, auto-updater binaries, crash reporters, telemetry trackers, and GPU cache. This tool provides a clean GUI to selectively remove or disable these components without affecting anything critical to Discord's core functionality.**

**It is designed so that Discord consumes only what is strictly necessary, reducing its overall resource usage and making it significantly lighter.**

---

## 📥 Installation / Usage

### Run the command below in PowerShell:

```ps1
iwr "https://raw.githubusercontent.com/insovs/Discord-Optimization/main/DiscordOptimizationTool.ps1" -OutFile "DiscordOptimizationTool.ps1"; .\DiscordOptimizationTool.ps1
```

or Download `DiscordDebloatTool.ps1`, then **right-click** it → **Run with PowerShell**

> [!CAUTION]
> If PowerShell scripts are blocked on your system, enable execution first:
> ```powershell
> Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
> ```
> Or use **[EnablePowerShellScript](https://github.com/insovs/EnablePowerShellScript)** for a one-click solution.

---

## ❓ FAQ

<details>
<summary><strong>Is this safe to use?</strong></summary>

Yes. The tool only removes files that Discord does not need to function (old versions, unused language packs, cache, telemetry modules). Nothing related to your account, messages, or servers is touched. You can enable the **backup option** in Advanced settings before running anything, which saves a full copy of your Discord folder to the Desktop.

</details>

<details>
<summary><strong>is it a virus ?</strong></summary>

No. PowerShell scripts that interact with the filesystem are commonly flagged as false positives by heuristic-based antivirus engines, especially when they modify program files or registry keys. This script contains no malicious code. You can verify this yourself:
- 📄 **The script is fully open-source** — read every line on this page before running it.
- 🔍 **VirusTotal scan:** [View latest scan results →](https://www.virustotal.com/gui/file/be5f19bddfbc2f75c46fd8ba9e0425be7b2190b1b96bfdbd37a07dde682f1d58/detection)

</details>

<details>
<summary><strong>I removed Game Presence / RPC and now FiveM / my game launcher can't link my account.</strong></summary>

The Game Presence module (`discord_game_sdk`) is required for some games (FiveM, certain launchers) to link your Discord account. To restore it: re-install Discord, or restore from the backup saved on your Desktop if you had the backup option enabled.

</details>

<details>
<summary><strong>Does this work on Discord PTB and Canary?</strong></summary>

Yes. The tool auto-detects which Discord variants are installed (Stable, PTB, Canary) and displays them with color-coded status indicators. You can run it on any detected variant.

</details>

<details>
<summary><strong>Can I restore my original Discord after debloating ?</strong></summary>

Yes, if you enabled the **backup option** before running. A full copy of your Discord installation is saved to your Desktop. To restore: close Discord, delete the current installation folder, rename the backup to the original folder name, and relaunch.

Alternatively, a clean reinstall from [discord.com](https://discord.com) will restore everything.

</details>

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
