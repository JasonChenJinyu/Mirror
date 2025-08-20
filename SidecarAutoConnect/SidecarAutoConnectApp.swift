import SwiftUI
import AppKit

@main
struct SidecarAutoConnectApp: App {
    @StateObject private var monitor = USBMonitor()   // ← your class (now public)
    @State private var autoConnectEnabled = false
    
    @State private var devices: [String] = []
    @State private var selectedDevice: String? = nil
    
    @Environment(\.openWindow) private var openWindow
    
    var body: some Scene {
        MenuBarExtra("Sidecar", systemImage: "ipad") {
            // Clean, list-only menu
            Toggle("Auto Connect iPad", isOn: $autoConnectEnabled)
                .onChange(of: autoConnectEnabled) { enabled in
                    if enabled {
                        monitor.startMonitoring()// ← use your method
                        if monitor.isIpadConnected(){
                            monitor.startSidecar()
                        }
                    } else {
                        // If you have a stop method, call it; otherwise remove this line.
                        monitor.stopMonitoring()
                    }
                }
            
            Divider()
            
            Menu("Connect") {
                if devices.isEmpty {
                    Button("Refresh Devices") { refreshDevices() }
                } else {
                    ForEach(devices, id: \.self) { name in
                        Button(name) { connect(to: name) }
                    }
                    Divider()
                    Button("Refresh Devices") { refreshDevices() }
                }
            }
            
            
            Button("Disconnect") {
                // If you prefer, you can also list devices here; this calls a generic disconnect.
                _ = runLauncher(["disconnect", selectedDevice ?? defaultFallbackDevice()])
            }
            
            Divider()
 
            Button("About…") {
                NSApp.activate(ignoringOtherApps: true)
                openWindow(id: "about")
            }
        
            Button("Quit") {
                NSApp.terminate(nil)
            }
        }
        WindowGroup(id: "about") {
            AboutView()
        }
    }
        
    func launcherURL() -> URL? {
        // Bundled SidecarLauncher binary (add it to Copy Bundle Resources)
        if let path = Bundle.main.path(forResource: "SidecarLauncher", ofType: nil) {
            // ensure it’s executable (helps in Debug if +x got lost)
            _ = try? FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: path)
            return URL(fileURLWithPath: path)
        }
        print("SidecarLauncher not found in app bundle Resources.")
        return nil
    }
    
    @discardableResult
    func runLauncher(_ args: [String]) -> (code: Int32, out: String) {
        guard let exe = launcherURL() else { return (127, "missing SidecarLauncher") }
        let p = Process()
        p.executableURL = exe
        p.arguments = args
        let pipe = Pipe()
        p.standardOutput = pipe
        p.standardError = pipe
        do { try p.run() } catch {
            let msg = "Failed to run SidecarLauncher: \(error.localizedDescription)"
            print(msg); return (126, msg)
        }
        p.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let out = String(data: data, encoding: .utf8) ?? ""
        print("SidecarLauncher \(args.joined(separator: " ")) → \(p.terminationStatus)\n\(out)")
        return (p.terminationStatus, out.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    func refreshDevices() {
        let r = runLauncher(["devices"])
        let list = r.out
            .split(separator: "\n")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        devices = list
        if selectedDevice == nil { selectedDevice = devices.first }
    }
    
    func connect(to name: String) {
        guard !name.isEmpty else { return }
        selectedDevice = name
        _ = runLauncher(["connect", name])
    }
    
    func defaultFallbackDevice() -> String {
        // used when Disconnect is pressed without a selection
        selectedDevice ?? devices.first ?? "Jason’s iPad"
    }
}
