# Mirror

A lightweight macOS menu bar utility to **auto-connect your iPad via Sidecar** when it’s plugged in.  
Written in SwiftUI + AppKit, with minimal dependencies, and bundled with a small launcher tool for Sidecar.

---

## Features
- 🖥️ Menu bar–only interface.
- 🔌 **Auto-connect toggle**: when enabled, the app monitors USB devices and auto-launches Sidecar when iPad is connected to the computer via USB.  
- 📱 **Device picker**: manually select from available devices and connect/disconnect.  
- 🔄 Refresh device at anytime.  
- ℹ️ Simple **About** window with copyright info.  
- ⏏️ Quit directly from the menu.

---

## Getting Started
1. Go to Release and download the latest version of the app.
2. Decompress the file and drag the App into your Application folder.

## Development Stack
- Language: Swift 5

- UI: SwiftUI + AppKit (MenuBarExtra)

- Minimum macOS: Ventura (13) or later

- Helper binary: SidecarLauncher (included in bundle)

### File Overview
- Mirror.swift → App entry & menu bar UI.

- USBMonitor.swift → Detects iPad USB connection, handles debounce logic, calls Sidecar.

- AboutView.swift → Simple SwiftUI about window.

- SidecarLauncher → Minimal CLI helper to trigger Sidecar actions (connect/disconnect/list devices).

## Note
This tool uses private Sidecar APIs and/or scripting. Behavior may break across macOS updates.
Use at your own risk.

## License
Mirror is licensed under MIT License.
Copyright © 2025 Jason Chen. All rights reserved.

