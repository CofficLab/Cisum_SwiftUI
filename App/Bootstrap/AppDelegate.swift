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
    var db = DB(AppConfig.getContainer())

    func applicationWillHide(_ notification: Notification) {
        os_log("\(self.label)WillHide")
    }

    func applicationDidHide(_ notification: Notification) {
        os_log("\(self.label)Did Hide 🐱🐱🐱")
    }
    
    func applicationWillBecomeActive(_ notification: Notification) {
        os_log("\(self.label)WillBecomeActive")
        
        Task {
            await db.stopGroupJob()
        }
    }
    
    func applicationDidFinishLaunching(_ notification: AppOrNotification) {
        os_log("\(self.label)applicationDidFinishLaunching")
    }

    func applicationWillTerminate(_ notification: AppOrNotification) {
        os_log("\(self.label)Will Terminate")
    }
    
    func applicationWillUpdate(_ notification: Notification) {
        //os_log("\(self.label)Will Update")
    }
    
    func applicationDidBecomeActive(_ notification: AppOrNotification) {
        os_log("\(self.label)Did Become Active")
    }
    
    func applicationWillResignActive(_ application: AppOrNotification) {
        // the app is about to become inactive and will lose focus.
        os_log("\(self.label)WillResignActive")
    }
    
    func applicationDidResignActive(_ notification: Notification) {
        os_log("\(self.label)DidResignActive")
        
//        Task.detached(priority: .background, operation: {
//            await self.db.getCovers()
//        })

        Task.detached(priority: .background, operation: {
            await self.db.findAudioGroupJob(verbose:true)
        })

        Task.detached(priority: .background, operation: {
            await self.db.prepareJob()
        })
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
