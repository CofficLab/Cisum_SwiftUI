import Foundation
import MagicCore
import OSLog
import SwiftUI

class BookSettingRepo {
    static let keyOfCurrentBookURL = "com.bookplugin.currentBookURL"
    static let keyOfCurrentBookTime = "com.bookplugin.currentBookTime"

    static func storeCurrent(_ url: URL?) {
        UserDefaults.standard.set(url, forKey: keyOfCurrentBookURL)

        // Store URL as string for CloudKit
        NSUbiquitousKeyValueStore.default.set(url?.absoluteString ?? "", forKey: keyOfCurrentBookURL)
        NSUbiquitousKeyValueStore.default.synchronize()
    }

    static func storeCurrentTime(_ time: TimeInterval) {
        UserDefaults.standard.set(time, forKey: keyOfCurrentBookTime)

        // Store time as string for CloudKit
        NSUbiquitousKeyValueStore.default.set(String(time), forKey: keyOfCurrentBookTime)
        NSUbiquitousKeyValueStore.default.synchronize()
    }

    static func getCurrent() -> URL? {
        // First, try to get the URL from UserDefaults
        if let url = UserDefaults.standard.url(forKey: keyOfCurrentBookURL) {
            return url
        }

        // If not found in UserDefaults, try to get from iCloud
        if let urlString = NSUbiquitousKeyValueStore.default.string(forKey: keyOfCurrentBookURL),
           let url = URL(string: urlString) {
            // If found in iCloud, update UserDefaults for future local access
            UserDefaults.standard.set(url, forKey: keyOfCurrentBookURL)
            return url
        }

        return nil
    }

    static func getCurrentTime() -> TimeInterval? {
        // First, try to get the time from UserDefaults
        let time = UserDefaults.standard.double(forKey: keyOfCurrentBookTime)
        if time > 0 { // Since 0 is the default value when key doesn't exist
            return time
        }

        // If not found in UserDefaults, try to get from iCloud
        if let timeString = NSUbiquitousKeyValueStore.default.string(forKey: keyOfCurrentBookTime),
           let time = TimeInterval(timeString) {
            // If found in iCloud, update UserDefaults for future local access
            UserDefaults.standard.set(time, forKey: keyOfCurrentBookTime)
            return time
        }

        return nil
    }
}

#if os(macOS)
    #Preview("App - Large") {
        AppPreview()
            .frame(width: 600, height: 1000)
    }

    #Preview("App - Small") {
        AppPreview()
            .frame(width: 500, height: 800)
    }
#endif

#if os(iOS)
    #Preview("iPhone") {
        AppPreview()
    }
#endif
