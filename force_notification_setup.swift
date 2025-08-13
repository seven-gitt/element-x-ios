#!/usr/bin/env swift

// Script để reset notification settings và force trigger device token registration
// Chạy script này để reset notification onboarding

import Foundation

print("🔧 Resetting notification onboarding settings...")

// Reset UserDefaults keys
let suiteName = "group.io.element.elementx.release" // Hoặc group.io.element.elementx.debug cho debug build
guard let userDefaults = UserDefaults(suiteName: suiteName) else {
    print("❌ Cannot access UserDefaults with suite name: \(suiteName)")
    exit(1)
}

// Reset notification-related keys
let keysToReset = [
    "hasRunNotificationPermissionsOnboarding",
    "enableNotifications",
    "enableInAppNotifications"
]

print("Resetting these keys:")
for key in keysToReset {
    let oldValue = userDefaults.object(forKey: key)
    userDefaults.removeObject(forKey: key)
    print("  - \(key): \(oldValue ?? "nil") → (removed)")
}

// Set enableNotifications to true explicitly
userDefaults.set(true, forKey: "enableNotifications")
userDefaults.set(false, forKey: "hasRunNotificationPermissionsOnboarding")

print("\n✅ Settings reset completed!")
print("📱 Now restart the app and login to trigger notification permissions screen")
