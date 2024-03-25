import AVFoundation
import AVKit
import MediaPlayer
import OSLog
import SwiftUI

#if os(iOS)
    class AppDelegate: NSObject, UIApplicationDelegate {
        func applicationWillTerminate(_ application: UIApplication) {
            AppConfig.logger.app.debug("🚩 Will  terminate")
        }

        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
            AppConfig.logger.app.debug("🚩 DidFinishLaunchingWithOptions")

            return true
        }
    }
#else
    class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
        func applicationDidFinishLaunching(_ notification: Notification) {
            os_log("🚩 applicationDidFinishLaunching")
        }

        func windowDidMove(_ notification: Notification) {
            AppConfig.logger.app.debug("移动窗口")
        }

        func windowDidResize(_ notification: Notification) {
            AppConfig.logger.app.debug("调整窗口")
        }
    }
#endif
