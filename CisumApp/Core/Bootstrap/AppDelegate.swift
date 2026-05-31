import AVFoundation
import AVKit
import MediaPlayer
import OSLog
import SwiftUI
import CoreFoundation

#if os(macOS)
    typealias ApplicationDelegate = NSApplicationDelegate
    typealias AppOrNotification = Notification
#else
    typealias ApplicationDelegate = UIApplicationDelegate
    typealias AppOrNotification = UIApplication
#endif

class AppDelegate: NSObject, ApplicationDelegate, SuperLog {
    var verbose = false
    nonisolated static let emoji: String = "🍎"
    var queue = DispatchQueue(label: "AppDelegate", qos: .background)

    func applicationWillHide(_ notification: Notification) {
        if self.verbose {
            os_log("\(self.t)WillHide")
        }
        NotificationCenter.postApplicationWillHide()
    }

    func applicationDidHide(_ notification: Notification) {
        if self.verbose {
            os_log("\(self.t)Did Hide 🐱🐱🐱")
        }
        NotificationCenter.postApplicationDidHide()
    }

    func applicationWillBecomeActive(_ notification: Notification) {
        if self.verbose {
            os_log("\(self.t)WillBecomeActive")
        }
        NotificationCenter.postApplicationWillBecomeActive()
    }

    func applicationDidFinishLaunching(_ notification: AppOrNotification) {
        if self.verbose {
            os_log("\(self.t)applicationDidFinishLaunching")
        }
        NotificationCenter.postApplicationDidFinishLaunching()
    }

    func applicationWillTerminate(_ notification: AppOrNotification) {
        if self.verbose {
            os_log("\(self.t)Will Terminate")
        }
        NotificationCenter.postApplicationWillTerminate()
    }

    func applicationWillUpdate(_ notification: Notification) {
        if self.verbose {
            os_log("\(self.t)Will Update")
        }
        NotificationCenter.postApplicationWillUpdate()
    }

    func applicationDidBecomeActive(_ notification: AppOrNotification) {
        if self.verbose {
            os_log("\(self.t)Did Become Active")
        }
        NotificationCenter.postApplicationDidBecomeActive()
    }

    func applicationWillResignActive(_ application: AppOrNotification) {
        if self.verbose {
            os_log("\(self.t)WillResignActive")
        }
        NotificationCenter.postApplicationWillResignActive()
    }

    func applicationDidResignActive(_ notification: Notification) {
        if self.verbose {
            os_log("\(self.t)DidResignActive")
        }
        NotificationCenter.postApplicationDidResignActive()
    }

    #if os(macOS)
        func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
            false
        }

        func application(_ app: NSApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
            false
        }

        func application(_ app: NSApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
            false
        }

        func application(_ app: NSApplication, shouldSaveSecureApplicationState coder: NSCoder) -> Bool {
            false
        }

        func application(_ app: NSApplication, shouldRestoreSecureApplicationState coder: NSCoder) -> Bool {
            false
        }

        func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
            guard !flag else { return true }
            guard let window = sender.windows.first else { return true }

            if window.isMiniaturized {
                window.deminiaturize(nil)
            }
            sender.activate(ignoringOtherApps: true)
            window.makeKeyAndOrderFront(nil)
            return false
        }
    #endif
}

// MARK: - 窗口调整

#if os(macOS)

    extension AppDelegate: NSWindowDelegate {
        func windowDidMove(_ notification: Notification) {
            if self.verbose {
                os_log("移动窗口")
            }
            NotificationCenter.postWindowDidMove()
        }

        func windowDidResize(_ notification: Notification) {
            if self.verbose {
                os_log("调整窗口")
            }
            NotificationCenter.postWindowDidResize()
        }
    }

#endif

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
