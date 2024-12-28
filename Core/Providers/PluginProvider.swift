import Foundation
import MagicKit
import MagicUI
import OSLog
import StoreKit
import SwiftData
import SwiftUI

class PluginProvider: ObservableObject, SuperLog, SuperThread {
    static let keyOfCurrentPluginID = "currentPluginID"
    static let emoji = "🧩"

    @Published private(set) var plugins: [SuperPlugin] = []
    @Published private(set) var current: SuperPlugin?

    var groupPlugins: [SuperPlugin] {
        plugins.filter { $0.isGroup }
    }

    init() {
        //os_log("\(self.i)")

        let currentPluginId = Self.getPluginId()

        if let plugin = plugins.first(where: { $0.id == currentPluginId }) {
            try? self.setCurrentGroup(plugin)
        }
    }

    func append(_ plugin: SuperPlugin, reason: String) throws {
        os_log("\(self.t)➕➕➕ Append: \(plugin.id) with reason: \(reason)")
        
        // Check if plugin with same ID already exists
        if plugins.contains(where: { $0.id == plugin.id }) {
            throw PluginProviderError.duplicatePluginID(plugin: plugin)
        }
        
        self.plugins.append(plugin)
    }
    
    func getStatusViews() -> [AnyView] {
        let items = plugins.compactMap { $0.addStatusView() }
        
        //os_log("\(self.t)GetRootViews: \(items.count)")
        
        return items
    }
    
    func getRootViews() -> [AnyView] {
        let items = plugins.compactMap { $0.addRootView() }
        
        //os_log("\(self.t)GetRootViews: \(items.count)")
        
        return items
    }
    
    func getSheetViews(storage: StorageLocation?) -> [AnyView] {
        let items = plugins.compactMap { $0.addSheetView(storage: storage) }
        
        //os_log("\(self.t)GetRootViews: \(items.count)")
        
        return items
    }

    func getToolBarButtons() -> [(id: String, view: AnyView)] {
        return current?.addToolBarButtons() ?? []
    }

    func setCurrentGroup(_ plugin: SuperPlugin) throws {
        //os_log("\(self.t)🏃🏃🏃 SetCurrentGroup: \(plugin.id)")

        if plugin.isGroup {
            self.current = plugin
            Self.storeCurrent(plugin)
        } else {
            throw PluginProviderError.PluginIsNotGroup(plugin: plugin)
        }
    }

    func restoreCurrent() throws {
        //os_log("\(self.t)🏃🏃🏃 RestoreCurrent")
        
        let currentPluginId = Self.getPluginId()

        if let plugin = plugins.first(where: { $0.id == currentPluginId }) {
            try self.setCurrentGroup(plugin)
        } else if let first = plugins.first(where: { $0.isGroup }) {
            try self.setCurrentGroup(first)
        }
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

enum PluginProviderError: Error, LocalizedError {
    case PluginIsNotGroup(plugin: SuperPlugin)
    case duplicatePluginID(plugin: SuperPlugin)

    var errorDescription: String? {
        switch self {
        case let .PluginIsNotGroup(plugin):
            return "Plugin \(plugin.id) is not a group"
        case let .duplicatePluginID(plugin):
            return "Plugin with ID \(plugin.id) already exists"
        }
    }
}
