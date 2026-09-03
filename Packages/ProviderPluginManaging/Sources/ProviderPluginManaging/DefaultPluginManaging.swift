import KernelCore
import CisumUIComponents
import Foundation

/// 直接读取 `BuiltinPluginManager` 的插件管理实现。
@MainActor
public final class DefaultPluginManaging: PluginManaging {
    public private(set) var lastErrorDescription: String?
    private let manager: BuiltinPluginManager
    private weak var kernel: CisumKernel?

    public init(manager: BuiltinPluginManager, kernel: CisumKernel) {
        self.manager = manager
        self.kernel = kernel
    }

    // MARK: - PluginManaging

    public var allPlugins: [any SuperPlugin] {
        manager.allPlugins
    }

    public var configurablePlugins: [any SuperPlugin] {
        manager.allPlugins.filter { type(of: $0).metadata.policy.allowUserToggle }
    }

    public var pluginCount: Int {
        manager.allPlugins.count
    }

    public var enabledCount: Int {
        manager.enabledPlugins.count
    }

    public func plugin(id: String) -> (any SuperPlugin)? {
        manager.plugin(by: id)
    }

    public func isRegistered(id: String) -> Bool {
        manager.plugin(by: id) != nil
    }

    public func enabledPlugins(from candidates: [any SuperPlugin]) -> [any SuperPlugin] {
        candidates.filter { manager.isPluginEnabled($0) }
    }

    // MARK: - Plugin Control

    public func enablePlugin(id: String) async -> Bool {
        guard let kernel else {
            lastErrorDescription = "Kernel is not available"
            return false
        }
        do {
            try await manager.enablePlugin(id: id, kernel: kernel)
            lastErrorDescription = nil
            return true
        } catch {
            lastErrorDescription = error.localizedDescription
            return false
        }
    }

    public func disablePlugin(id: String) async -> Bool {
        guard let kernel else {
            lastErrorDescription = "Kernel is not available"
            return false
        }
        do {
            try await manager.disablePlugin(id: id, kernel: kernel)
            lastErrorDescription = nil
            return true
        } catch {
            lastErrorDescription = error.localizedDescription
            return false
        }
    }

    public func isEnabled(id: String) -> Bool {
        guard let plugin = manager.plugin(by: id) else { return false }
        return manager.isPluginEnabled(plugin)
    }
}