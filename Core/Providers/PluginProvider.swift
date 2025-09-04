import Foundation
import MagicCore
import OSLog
import StoreKit
import SwiftData
import SwiftUI

@MainActor
class PluginProvider: ObservableObject, SuperLog, SuperThread {
    nonisolated static let emoji = "🧩"
    
    private let repo: PluginRepo

    @Published private(set) var plugins: [SuperPlugin] = []
    @Published private(set) var current: SuperPlugin?

    var groupPlugins: [SuperPlugin] {
        plugins.filter { $0.isGroup }
    }

    init(plugins: [SuperPlugin], repo: PluginRepo) {
        os_log("\(Self.onInit)")

        self.plugins = plugins
        self.repo = repo
        let currentPluginId = repo.getCurrentPluginId()

        if let plugin = plugins.first(where: { $0.id == currentPluginId }) {
            try? self.setCurrentGroup(plugin)
        }
    }

    func getStatusViews() -> [AnyView] {
        let items = plugins.compactMap { $0.addStatusView() }

        // os_log("\(self.t)GetRootViews: \(items.count)")

        return items
    }

    func wrapWithCurrentRoot<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        guard let current = current else { return nil }
        return current.addRootView { content() }
    }

    func getSheetViews(storage: StorageLocation?) -> [AnyView] {
        let items = plugins.compactMap { $0.addSheetView(storage: storage) }

        // os_log("\(self.t)GetRootViews: \(items.count)")

        return items
    }

    func getToolBarButtons(verbose: Bool = true) -> [(id: String, view: AnyView)] {
        let buttons =  plugins.flatMap { $0.addToolBarButtons() }
        
        if verbose {
            os_log("\(self.t)🏃🏃🏃 getToolBarButtons: \(buttons.count)")
        }
        
        return buttons
    }

    func setCurrentGroup(_ plugin: SuperPlugin, verbose: Bool = false) throws {
        if verbose {
            os_log("\(self.t)🏃🏃🏃 SetCurrentGroup: \(plugin.id)")
        }

        if plugin.isGroup {
            self.current = plugin
            repo.storeCurrentPluginId(plugin.id)
        } else {
            throw PluginProviderError.pluginIsNotGroup(pluginId: plugin.id)
        }
    }

    func reset() {
        self.plugins = []
        self.current = nil
    }

    func restoreCurrent() throws {
        let currentPluginId = repo.getCurrentPluginId()

        if let plugin = plugins.first(where: { $0.id == currentPluginId }) {
            try self.setCurrentGroup(plugin)
        } else if let first = plugins.first(where: { $0.isGroup }) {
            try self.setCurrentGroup(first)
        } else {
            os_log(.error, "\(self.t)⚠️⚠️⚠️ No current plugin found")
        }
    }
}

// MARK: Event

extension PluginProvider {
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
            await plugin.onDisappear()
        }
    }

    func handleOnAppear(playMan: PlayManWrapper, current: SuperPlugin?, storage: StorageLocation?) async throws {
        for plugin in plugins {
            try await plugin.onWillAppear(playMan: playMan, currentGroup: current, storage: storage)
        }
    }

    func onPlayNext(current: URL?, mode: PlayMode, man: PlayManWrapper) async throws {
        let currentGroupId = self.current?.id
        for plugin in plugins {
            try await plugin.onPlayNext(playMan: man, current: current, currentGroup: currentGroupId, verbose: true)
        }
    }

    func onPlayPrev(current: URL?, mode: PlayMode, man: PlayManWrapper) async throws {
        let currentGroupId = self.current?.id
        for plugin in plugins {
            try await plugin.onPlayPrev(playMan: man, current: current, currentGroup: currentGroupId, verbose: true)
        }
    }

    func onPlayModeChange(mode: PlayMode, asset: URL?) async throws {
        for plugin in plugins {
            try await plugin.onPlayModeChange(mode: mode.rawValue, asset: asset)
        }
    }

    func onLike(asset: URL?, liked: Bool) async throws {
        for plugin in plugins {
            try await plugin.onLike(asset: asset, liked: liked)
        }
    }

    func onCurrentURLChanged(url: URL) async throws {
        for plugin in plugins {
            try await plugin.onCurrentURLChanged(url: url)
        }
    }

    func onPause(man: PlayManWrapper) async throws {
        for plugin in plugins {
            await plugin.onPause(playMan: man)
        }
    }
}

// MARK: - Error

enum PluginProviderError: Error, LocalizedError {
    case pluginIsNotGroup(pluginId: String)
    case duplicatePluginID(pluginId: String, collection: [String])
    case pluginIDIsEmpty

    var errorDescription: String? {
        switch self {
        case let .pluginIsNotGroup(pluginId):
            return "Plugin \(pluginId) is not a group"
        case let .duplicatePluginID(pluginId, collection):
            return "Plugin with ID \(pluginId) already exists in collection: \(collection)"
        case .pluginIDIsEmpty:
            return "Plugin has an empty ID"
        }
    }
}

#if os(macOS)
#Preview("Small Screen") {
    RootView {
        ContentView()
    }
    .frame(width: 500)
    .frame(height: 600)
}

#Preview("Big Screen") {
    RootView {
        ContentView()
    }
    .frame(width: 800)
    .frame(height: 1200)
}
#endif

#if os(iOS)
#Preview("iPhone") {
    AppPreview()
}
#endif
