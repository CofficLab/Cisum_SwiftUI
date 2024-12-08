import Foundation
import MagicKit
import OSLog
import StoreKit
import SwiftData
import SwiftUI

class PluginProvider: ObservableObject, SuperLog, SuperThread {
    static let keyOfCurrentPluginID = "currentPluginID"
    let emoji = "🧩"

    @Published var plugins: [SuperPlugin] = []
    @Published var current: SuperPlugin?

    init() {
        os_log("\(Logger.initLog) PluginProvider")

        let currentPluginId = Self.getPluginId()

        if let plugin = plugins.first(where: { $0.id == currentPluginId }) {
            os_log("  ➡️ Set Current Plugin: \(plugin.id)")
            self.current = plugin
        }
    }

    func append(_ plugin: SuperPlugin) {
        self.plugins.append(plugin)
    }

    func setCurrent(_ plugin: SuperPlugin) {
        self.current = plugin
        Self.storeCurrent(plugin)
    }

    static func storeCurrent(_ plugin: SuperPlugin) {
        let id = plugin.id

        UserDefaults.standard.set(id, forKey: keyOfCurrentPluginID)

        // Synchronize with CloudKit
        NSUbiquitousKeyValueStore.default.set(id, forKey: keyOfCurrentPluginID)
        NSUbiquitousKeyValueStore.default.synchronize()
    }

    static func getPluginId() -> String {
        // First, try to get the layout ID from UserDefaults
        if let id = UserDefaults.standard.string(forKey: keyOfCurrentPluginID) {
            return id
        }

        // If not found in UserDefaults, try to get from iCloud
        if let id = NSUbiquitousKeyValueStore.default.string(forKey: keyOfCurrentPluginID) {
            // If found in iCloud, update UserDefaults for future local access
            UserDefaults.standard.set(id, forKey: keyOfCurrentPluginID)
            return id
        }

        return ""
    }
}
