#!/usr/bin/env swift

import Foundation

// Reset notification settings to force onboarding screen
print("🔧 Force resetting notification settings...")

// For release build
let suiteName = "group.io.element.elementx.release"
guard let userDefaults = UserDefaults(suiteName: suiteName) else {
    print("❌ Cannot access UserDefaults with suite: \(suiteName)")
    print("Trying debug suite...")
    
    // For debug build
    let debugSuite = "group.io.element.elementx.debug"
    guard let debugDefaults = UserDefaults(suiteName: debugSuite) else {
        print("❌ Cannot access debug suite either: \(debugSuite)")
        exit(1)
    }
    
    print("✅ Using debug suite")
    debugDefaults.set(false, forKey: "hasRunNotificationPermissionsOnboarding")
    debugDefaults.set(true, forKey: "enableNotifications")
    debugDefaults.synchronize()
    print("✅ Debug settings reset!")
    exit(0)
}

// Reset notification onboarding
userDefaults.set(false, forKey: "hasRunNotificationPermissionsOnboarding")
userDefaults.set(true, forKey: "enableNotifications")
userDefaults.synchronize()

print("✅ Release settings reset!")
print("📱 Delete and reinstall app, then test again")
