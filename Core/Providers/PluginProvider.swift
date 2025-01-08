import Foundation
import MagicKit
import MagicUI
import OSLog
import StoreKit
import SwiftData
import SwiftUI

@MainActor
class PluginProvider: ObservableObject, @preconcurrency SuperLog, SuperThread {
    static let keyOfCurrentPluginID = "currentPluginID"
    static let emoji = "🧩"

    @Published private(set) var plugins: [SuperPlugin] = []
    @Published private(set) var current: SuperPlugin?

    var groupPlugins: [SuperPlugin] {
        plugins.filter { $0.isGroup }
    }

    init() {
        // os_log("\(self.i)")

        let currentPluginId = Self.getPluginId()

        if let plugin = plugins.first(where: { $0.id == currentPluginId }) {
            try? self.setCurrentGroup(plugin)
        }
    }

    func append(_ plugin: SuperPlugin, reason: String) throws {
        let verbose = false

        if verbose {
            os_log("\(self.t)➕➕➕ Append: \(plugin.id) with reason: \(reason)")
        }

        if plugin.id.isEmpty {
            throw PluginProviderError.pluginIDIsEmpty
        }

        // Check if plugin with same ID already exists
        if plugins.contains(where: { $0.id == plugin.id }) {
            throw PluginProviderError.duplicatePluginID(pluginId: plugin.id)
        }

        self.plugins.append(plugin)
    }

    func getStatusViews() -> [AnyView] {
        let items = plugins.compactMap { $0.addStatusView() }

        // os_log("\(self.t)GetRootViews: \(items.count)")

        return items
    }

    func getRootViews() -> [AnyView] {
        let items = plugins.compactMap { $0.addRootView() }

        // os_log("\(self.t)GetRootViews: \(items.count)")

        return items
    }

    func getSheetViews(storage: StorageLocation?) -> [AnyView] {
        let items = plugins.compactMap { $0.addSheetView(storage: storage) }

        // os_log("\(self.t)GetRootViews: \(items.count)")

        return items
    }

    func getToolBarButtons() -> [(id: String, view: AnyView)] {
        return current?.addToolBarButtons() ?? []
    }

    func setCurrentGroup(_ plugin: SuperPlugin) throws {
        os_log("\(self.t)🏃🏃🏃 SetCurrentGroup: \(plugin.id)")

        if plugin.isGroup {
            self.current = plugin
            Self.storeCurrent(plugin)
        } else {
            throw PluginProviderError.pluginIsNotGroup(pluginId: plugin.id)
        }
    }

    func reset() {
        self.plugins = []
        self.current = nil
    }

    func restoreCurrent() throws {
        let currentPluginId = Self.getPluginId()

        if let plugin = plugins.first(where: { $0.id == currentPluginId }) {
            try self.setCurrentGroup(plugin)
        } else if let first = plugins.first(where: { $0.isGroup }) {
            try self.setCurrentGroup(first)
        } else {
            os_log(.error, "\(self.t)⚠️⚠️⚠️ No current plugin found")
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

    func executePluginOperation(_ operation: @Sendable (SuperPlugin) async throws -> Void) async {
        for plugin in plugins {
            do {
                try await operation(plugin)
            } catch {
                os_log(.error, "\(self.t)Plugin operation failed: \(error.localizedDescription)")
            }
        }
    }

    func handleStorageLocationChange(storage: StorageLocation?) async throws {
        for plugin in plugins {
            try await plugin.onStorageLocationChange(storage: storage)
        }
    }

    func handlePlayStateUpdate() async throws {
        for plugin in plugins {
            try await plugin.onPlayStateUpdate()
        }
    }

    func handleOnDisappear() async throws {
        for plugin in plugins {
            try await plugin.onDisappear()
        }
    }
    
    func handleOnAppear(playMan: PlayManWrapper, current: SuperPlugin?, storage: StorageLocation?) async throws {
        for plugin in plugins {
            try await plugin.onWillAppear(playMan: playMan, currentGroup: current, storage: storage)
        }
    }
}

enum PluginProviderError: Error, LocalizedError {
    case pluginIsNotGroup(pluginId: String)
    case duplicatePluginID(pluginId: String)
    case pluginIDIsEmpty

    var errorDescription: String? {
        switch self {
        case let .pluginIsNotGroup(pluginId):
            return "Plugin \(pluginId) is not a group"
        case let .duplicatePluginID(pluginId):
            return "Plugin with ID \(pluginId) already exists"
        case .pluginIDIsEmpty:
            return "Plugin has an empty ID"
        }
    }
}
