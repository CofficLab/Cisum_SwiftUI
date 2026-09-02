import CisumKernel
import CisumUI
import Foundation

/// 插件管理数据协议（对齐 Lumi `ProviderPluginManaging/PluginManaging`）。
///
/// 设置中的插件管理页通过它读取全部插件与启用状态，并通过继承的
/// `PluginControlling` 启停插件。
@MainActor
public protocol PluginManaging: PluginControlling {
    /// 全部已注册插件（含未启用的）。
    var allPlugins: [any SuperPlugin] { get }

    /// 仅用户可配置的插件（policy 允许用户切换：optOut / optIn）。
    var configurablePlugins: [any SuperPlugin] { get }

    /// 已注册插件总数。
    var pluginCount: Int { get }

    /// 当前启用插件数。
    var enabledCount: Int { get }

    /// 按 id 查找插件。
    func plugin(id: String) -> (any SuperPlugin)?

    /// 判断插件是否已注册。
    func isRegistered(id: String) -> Bool

    /// 从候选插件中筛出当前启用的。
    func enabledPlugins(from candidates: [any SuperPlugin]) -> [any SuperPlugin]
}

/// 直接读取 `BuiltinPluginManager` 的插件管理实现。
@MainActor
public final class DefaultPluginManaging: PluginManaging {
    public private(set) var lastErrorDescription: String?
    private let manager: BuiltinPluginManager
    private let controlling: PluginControlling

    public init(manager: BuiltinPluginManager, kernel: CisumKernel) {
        self.manager = manager
        self.controlling = DefaultPluginControlling(manager: manager, kernel: kernel)
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

    // MARK: - PluginControlling

    public func enablePlugin(id: String) async -> Bool {
        await controlling.enablePlugin(id: id)
    }

    public func disablePlugin(id: String) async -> Bool {
        await controlling.disablePlugin(id: id)
    }

    public func isEnabled(id: String) -> Bool {
        controlling.isEnabled(id: id)
    }
}
