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

class AppDelegate: NSObject, ApplicationDelegate {
    var verbose = false
    var label: String { "\(Logger.isMain)🍎 AppDelegate::" }
    var queue = DispatchQueue(label: "AppDelegate", qos: .background)

    func applicationWillHide(_ notification: Notification) {
        queue.async {
            os_log("\(self.label)WillHide")
        }
    }

    func applicationDidHide(_ notification: Notification) {
        queue.async {
            os_log("\(self.label)Did Hide 🐱🐱🐱")
        }
    }

    func applicationWillBecomeActive(_ notification: Notification) {
        queue.async {
            os_log("\(self.label)WillBecomeActive")
        }
    }

    func applicationDidFinishLaunching(_ notification: AppOrNotification) {
        queue.async {
            os_log("\(self.label)applicationDidFinishLaunching")
        }
    }

    func applicationWillTerminate(_ notification: AppOrNotification) {
        queue.async {
            os_log("\(self.label)Will Terminate")
        }
    }

    func applicationWillUpdate(_ notification: Notification) {
        // os_log("\(self.label)Will Update")
    }

    func applicationDidBecomeActive(_ notification: AppOrNotification) {
        queue.async {
            os_log("\(self.label)Did Become Active")
        }
    }

    func applicationWillResignActive(_ application: AppOrNotification) {
        queue.async {
            os_log("\(self.label)WillResignActive")
        }
    }

    func applicationDidResignActive(_ notification: Notification) {
        queue.async {
            os_log("\(self.label)DidResignActive")
        }
    }
}

// MARK: 窗口调整

#if os(macOS)

extension AppDelegate: NSWindowDelegate {
    func windowDidMove(_ notification: Notification) {
        os_log("移动窗口")
    }

    func windowDidResize(_ notification: Notification) {
        os_log("调整窗口")
    }
}

#endif
