import AVFoundation
import AVKit
import MediaPlayer
import OSLog
import SwiftUI

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
        NotificationCenter.default.post(name: .applicationWillHide, object: self)
    }

    func applicationDidHide(_ notification: Notification) {
        if self.verbose {
            os_log("\(self.t)Did Hide 🐱🐱🐱")
        }
        NotificationCenter.default.post(name: .applicationDidHide, object: self)
    }

    func applicationWillBecomeActive(_ notification: Notification) {
        if self.verbose {
            os_log("\(self.t)WillBecomeActive")
        }
        NotificationCenter.default.post(name: .applicationWillBecomeActive, object: self)
    }

    func applicationDidFinishLaunching(_ notification: AppOrNotification) {
        if self.verbose {
            os_log("\(self.t)applicationDidFinishLaunching")
        }
        NotificationCenter.default.post(name: .applicationDidFinishLaunching, object: self)
    }

    func applicationWillTerminate(_ notification: AppOrNotification) {
        if self.verbose {
            os_log("\(self.t)Will Terminate")
        }
        NotificationCenter.default.post(name: .applicationWillTerminate, object: self)
    }

    func applicationWillUpdate(_ notification: Notification) {
        if self.verbose {
            os_log("\(self.t)Will Update")
        }
        NotificationCenter.default.post(name: .applicationWillUpdate, object: self)
    }

    func applicationDidBecomeActive(_ notification: AppOrNotification) {
        if self.verbose {
            os_log("\(self.t)Did Become Active")
        }
        NotificationCenter.default.post(name: .applicationDidBecomeActive, object: self)
    }

    func applicationWillResignActive(_ application: AppOrNotification) {
        if self.verbose {
            os_log("\(self.t)WillResignActive")
        }
        NotificationCenter.default.post(name: .applicationWillResignActive, object: self)
    }

    func applicationDidResignActive(_ notification: Notification) {
        if self.verbose {
            os_log("\(self.t)DidResignActive")
        }
        NotificationCenter.default.post(name: .applicationDidResignActive, object: self)
    }
}

// MARK: - 窗口调整

#if os(macOS)

    extension AppDelegate: NSWindowDelegate {
        func windowDidMove(_ notification: Notification) {
            if self.verbose {
                os_log("移动窗口")
            }
            NotificationCenter.default.post(name: .windowDidMove, object: self)
        }

        func windowDidResize(_ notification: Notification) {
            if self.verbose {
                os_log("调整窗口")
            }
            NotificationCenter.default.post(name: .windowDidResize, object: self)
        }
    }

#endif
