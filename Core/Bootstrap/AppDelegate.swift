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
    }

    func applicationDidHide(_ notification: Notification) {
        if self.verbose {
            os_log("\(self.t)Did Hide 🐱🐱🐱")
        }
    }

    func applicationWillBecomeActive(_ notification: Notification) {
        if self.verbose {
            os_log("\(self.t)WillBecomeActive")
        }
    }

    func applicationDidFinishLaunching(_ notification: AppOrNotification) {
        if self.verbose {
            os_log("\(self.t)applicationDidFinishLaunching")
        }
    }

    func applicationWillTerminate(_ notification: AppOrNotification) {
        if self.verbose {
            os_log("\(self.t)Will Terminate")
        }
    }

    func applicationWillUpdate(_ notification: Notification) {
        if self.verbose {
            os_log("\(self.t)Will Update")
        }
    }

    func applicationDidBecomeActive(_ notification: AppOrNotification) {
        if self.verbose {
            os_log("\(self.t)Did Become Active")
        }
    }

    func applicationWillResignActive(_ application: AppOrNotification) {
        if self.verbose {
            os_log("\(self.t)WillResignActive")
        }
    }

    func applicationDidResignActive(_ notification: Notification) {
        if self.verbose {
            os_log("\(self.t)DidResignActive")
        }
    }
}

// MARK: - 窗口调整

#if os(macOS)

    extension AppDelegate: NSWindowDelegate {
        func windowDidMove(_ notification: Notification) {
            if self.verbose {
                os_log("移动窗口")
            }
        }

        func windowDidResize(_ notification: Notification) {
            if self.verbose {
                os_log("调整窗口")
            }
        }
    }

#endif
