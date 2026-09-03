import KernelCore
import CisumUIComponents
import Foundation

/// 插件管理数据协议（对齐 Lumi `ProviderPluginManaging/PluginManaging`）。
///
/// 设置中的插件管理页通过它读取全部插件与启用状态，并驱动运行期启停
/// （写入用户覆盖 + 重建贡献 + 持久化）。
@MainActor
public protocol PluginManaging: AnyObject {
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

    /// 最近一次启停操作的错误描述（供设置页展示）。
    var lastErrorDescription: String? { get }

    /// 运行期启用插件。
    ///
    /// - Returns: 是否成功；失败时 `lastErrorDescription` 记录原因。
    func enablePlugin(id: String) async -> Bool

    /// 运行期禁用插件。
    ///
    /// - Returns: 是否成功；失败时 `lastErrorDescription` 记录原因。
    func disablePlugin(id: String) async -> Bool

    /// 判断插件当前是否启用（结合策略 + 用户覆盖）。
    func isEnabled(id: String) -> Bool
}

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
