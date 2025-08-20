import Foundation
import ApplicationServices
import UserNotifications

func ensureAccessibilityPermission() {
    let opts = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
    let trusted = AXIsProcessTrustedWithOptions(opts)
    if !trusted {
        print("⚠️ Accessibility not granted — user should see a popup now.")
    }
}

func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if let error = error {
            print("Notification error: \(error)")
        }
        if !granted {
            print("⚠️ Notifications denied")
        }
    }
}
