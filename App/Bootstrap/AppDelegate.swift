import AVFoundation
import AVKit
import MediaPlayer
import OSLog
import SwiftUI

#if os(macOS)
    class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
        var verbose = false
        var label: String { "\(Logger.isMain)🍎 AppDelegate::"}
        
        func applicationDidFinishLaunching(_ notification: Notification) {
            os_log("\(self.label)applicationDidFinishLaunching")
        }

        func windowDidMove(_ notification: Notification) {
            os_log("移动窗口")
        }

        func windowDidResize(_ notification: Notification) {
            os_log("调整窗口")
        }

        func applicationWillTerminate(_ notification: Notification) {
            os_log("\(self.label)Will Terminate")
        }

        func applicationDidBecomeActive(_ notification: Notification) {
            os_log("\(self.label)Did Become Active")
        }
        
        func applicationDidHide(_ notification: Notification) {
            os_log("\(self.label)Did Hide 🐱🐱🐱")
        }
    }
#else
    class AppDelegate: NSObject, UIApplicationDelegate {
        func applicationWillTerminate(_ application: UIApplication) {
            AppConfig.logger.app.debug("🚩 Will  terminate")
        }

        func application(
            _ application: UIApplication,
            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
        ) -> Bool {
            AppConfig.logger.app.debug("🚩 DidFinishLaunchingWithOptions")

            return true
        }
    }
#endif
