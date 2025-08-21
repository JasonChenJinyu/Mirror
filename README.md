# SidecarAutoConnect

A lightweight macOS menu bar utility to **auto-connect your iPad via Sidecar** when it’s plugged in.  
Written in SwiftUI + AppKit, with minimal dependencies, and bundled with a small launcher tool for Sidecar.

---

## ✨ Features
- 🖥️ Menu bar–only interface (no cluttered window UI).  
- 🔌 **Auto-connect toggle**: when enabled, the app monitors USB devices and auto-launches Sidecar if your iPad is detected.  
- 📱 **Device picker**: manually select from available devices and connect/disconnect.  
- 🔄 Refresh device list anytime.  
- ℹ️ Simple **About** window with copyright info.  
- ⏏️ Quit directly from the menu.

---

## 📦 Installation
1. Clone this repo:
   ```bash
   git clone https://github.com/<your-username>/SidecarAutoConnect.git```
2. Open SidecarAutoConnect.xcodeproj in Xcode.

3. Build & run. The app will appear as an iPad icon in the menu bar.

## 🔑 Permissions
The app automates parts of Sidecar. macOS may ask you to grant:

1. Accessibility access (for UI automation via AppleScript, if used).

2. Screen Recording if you want to use Sidecar screen sharing features.

Make sure you grant these in System Settings → Privacy & Security.

## 🛠️ Development
- Language: Swift 5

- UI: SwiftUI + AppKit (MenuBarExtra)

- Minimum macOS: Ventura (13) or later

- Helper binary: SidecarLauncher (included in bundle)

### File Overview
- SidecarAutoConnectApp.swift → App entry & menu bar UI.

- USBMonitor.swift → Detects iPad USB connection, handles debounce logic, calls Sidecar.

- AboutView.swift → Simple SwiftUI about window.

- SidecarLauncher → Minimal CLI helper to trigger Sidecar actions (connect/disconnect/list devices).

## ⚠️ Disclaimer
This tool uses private Sidecar APIs and/or scripting. Behavior may break across macOS updates.
Use at your own risk.

## 📜 License
MIT License © 2025 Jason Chen
Feel free to fork, modify, and share.
