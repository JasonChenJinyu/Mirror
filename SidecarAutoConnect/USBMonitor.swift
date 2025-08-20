import Foundation
import Combine
import UserNotifications
import AppKit
final class USBMonitor: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    @Published var connected = false

    private var timer: Timer?
    private var lastState = false
    private let debounceSeconds = 1

    override init() {
        super.init()
        configureNotifications()
    }

    // MARK: - Public
    func manualTrigger() {
        // Manually try Sidecar (useful if it didn’t auto-trigger)
        startSidecar()
    }
    
    
    enum SidecarCtl {
        static func run(_ args: [String]) -> (status: Int32, output: String) {
            guard let exe = Bundle.main.path(forResource: "SidecarLauncher", ofType: nil) else {
                return (127, "SidecarLauncher not found in bundle Resources")
            }

            // Ensure executable bit at runtime (helps in Debug/dev copies)
            _ = try? FileManager.default.setAttributes([.posixPermissions: 0o755],
                                                       ofItemAtPath: exe)

            let task = Process()
            task.launchPath = exe
            task.arguments = args

            let pipe = Pipe()
            task.standardOutput = pipe
            task.standardError = pipe
            do { try task.run() } catch {
                return (126, "Failed to run SidecarLauncher: \(error)")
            }
            task.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let out = String(data: data, encoding: .utf8) ?? ""
            return (task.terminationStatus, out)
        }

        static func list() -> String {
            let r = run(["devices"])
            return r.output
        }

        static func connect(_ name: String) -> (Int32, String) {
            run(["connect", name])
        }

        static func disconnect(_ name: String) -> (Int32, String) {
            run(["disconnect", name])
        }
    }
    
    // MARK: - USB polling (simple & robust without extra deps)
    func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            let detected = self.isIpadConnected()
            if detected && !self.lastState {
                // Rising edge → require stable debounce
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(self.debounceSeconds)) {
                    if self.isIpadConnected() && !self.lastState {
                        self.connected = true
                        self.lastState = true
                        self.notify("iPad connected – starting Sidecar…")
                        self.startSidecar()
                    }
                }
            } else if !detected && self.lastState {
                // Falling edge
                self.connected = false
                self.lastState = false
                self.notify("iPad disconnected.")
            }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    func stopMonitoring() {
        if let t = timer {
            t.invalidate()
            timer = nil
        }
        lastState = false
        connected = false
        notify("Auto-connect stopped.")
    }
    
    func isIpadConnected() -> Bool {
        // ioreg -p IOUSB -w0 | grep -w iPad
        let task = Process()
        task.launchPath = "/usr/sbin/ioreg"
        task.arguments = ["-p", "IOUSB", "-w0"]

        let out = Pipe()
        task.standardOutput = out
        do {
            try task.run()
        } catch {
            return false
        }
        task.waitUntilExit()

        let data = out.fileHandleForReading.readDataToEndOfFile()
        guard let s = String(data: data, encoding: .utf8) else { return false }
        return s.contains("iPad") // simple + effective
    }

    // MARK: - Sidecar trigger via AppleScript (bundled .scpt, with diagnostics)
    func startSidecar() {
        print("DEBUG: SidecarLauncher devices…")
        let devices = SidecarCtl.list()
        print(devices)

        // Pick either the first iPad or a user-specified name
        // If you have a single iPad, this simple pick works:
        guard let ipad = devices
                .split(separator: "\n")
                .map({ String($0).trimmingCharacters(in: .whitespaces) })
                .first(where: { !$0.isEmpty }) else {
            print("No Sidecar devices reported.")
            return
        }

        print("DEBUG: Connecting to: \(ipad)")
        let (code, out) = SidecarCtl.connect(ipad)
        print("Exit:\(code)\n\(out)")
    }

    

    // MARK: - Notifications (modern API, no console spam)
    private func configureNotifications() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
        center.delegate = self
    }
    
    

    func notify(_ message: String) {
        let content = UNMutableNotificationContent()
        content.title = "Sidecar USB"
        content.body = message

        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    // Foreground delivery
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.banner, .sound]
    }
}
