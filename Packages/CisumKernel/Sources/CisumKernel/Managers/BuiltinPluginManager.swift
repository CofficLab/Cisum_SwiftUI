import CisumUI
import Foundation
import MagicKit
import OSLog

/// 内置插件管理器。
///
/// 负责插件的注册、两阶段生命周期管理和启用状态控制。
///
/// ## 启动流程
///
/// ```
/// initializePlugins([myPlugin, ...])
///     ↓
/// onBoot(kernel:)    ← 阶段 1: 插件注册内核服务
///     ↓
/// onReady(kernel:)   ← 阶段 2: 插件执行依赖服务的异步初始化
/// ```
///
/// ## 插件启用策略
///
/// - 内核级插件 (`Policy.alwaysOn`): 始终启用，不可被用户禁用。
/// - 可配置插件 (`Policy.optOut` / `Policy.optIn`): 用户可通过
///   `PluginEnabledStateStore` 覆盖启用状态。
/// - 禁用插件 (`Policy.disabled`): 始终禁用，不可被用户启用。
@MainActor
public final class BuiltinPluginManager: ObservableObject {
    nonisolated(unsafe) public static var verbose = false
    nonisolated static let emoji = "🧩"

    /// 弱引用回到内核容器。
    weak var kernel: CisumKernelContainer?

    /// 所有已注册的插件实例（以版本化类型名称为键的字典，按注册顺序排序）。
    private var pluginRegistry: [String: any SuperPlugin] = [:]

    /// 版本化类型名称列表，保留注册顺序。
    private var orderedPluginKeys: [String] = []

    /// 插件启用状态持久化存储。
    private let stateStore = PluginEnabledStateStore()

    /// 已使用的插件 ID 集合，用于检测重复。
    private var usedIDs: Set<String> = []

    public init() {}

    // MARK: - Plugin Initialization

    /// 初始化插件列表。
    ///
    /// 调用此方法后，所有插件实例被注册到内部注册表中。
    /// 此方法应在 `startup()` 之前调用。
    ///
    /// - Parameter plugins: 插件实例数组，按注册顺序排列。
    public func initializePlugins(_ plugins: [any SuperPlugin]) {
        pluginRegistry.removeAll()
        orderedPluginKeys.removeAll()
        usedIDs.removeAll()

        for plugin in plugins {
            register(plugin)
        }

        if Self.verbose {
            os_log("\(Self.t)✅ Initialized \(self.pluginRegistry.count) plugins")
        }
    }

    // MARK: - Lifecycle Phases

    /// 阶段 1: OnBoot —— 注册内核服务。
    ///
    /// 遍历所有已启用的插件，调用其 `onBoot(kernel:)`（如果实现了 `CisumKernelPlugin`）。
    /// 然后再对仅实现 `SuperPlugin` 的插件调用 `onRegister()` / `onEnable()`。
    ///
    /// - Parameter kernel: 内核容器实例。
    func onBoot(kernel: CisumKernelContainer) async throws {
        guard !pluginRegistry.isEmpty else {
            if Self.verbose { os_log("\(Self.t)⚠️ No plugins initialized, skipping onBoot") }
            return
        }

        for key in orderedPluginKeys {
            guard let plugin = pluginRegistry[key] else { continue }
            guard isPluginEnabled(plugin) else {
                if Self.verbose { os_log("\(Self.t)⏭️ Skipping disabled plugin: \(plugin.id)") }
                continue
            }

            // 如果是内核感知插件，调用两阶段生命周期
            if let kernelPlugin = plugin as? any CisumKernelPlugin {
                if Self.verbose { os_log("\(Self.t)🔌 onBoot for kernel plugin: \(plugin.id)") }
                try await kernelPlugin.onBoot(kernel: kernel)
            } else {
                // 标准 SuperPlugin: 调用 onRegister + onEnable
                if Self.verbose { os_log("\(Self.t)📋 onRegister for: \(plugin.id)") }
                plugin.onRegister()
                plugin.onEnable()
            }
        }
    }

    /// 阶段 2: OnReady —— 依赖服务的异步初始化。
    ///
    /// 在所有 `onBoot` 完成后统一调用所有内核感知插件的 `onReady(kernel:)`。
    ///
    /// - Parameter kernel: 内核容器实例。
    func onReady(kernel: CisumKernelContainer) async throws {
        for key in orderedPluginKeys {
            guard let plugin = pluginRegistry[key] else { continue }
            guard let kernelPlugin = plugin as? any CisumKernelPlugin else { continue }
            guard isPluginEnabled(plugin) else { continue }

            if Self.verbose { os_log("\(Self.t)🚀 onReady for: \(plugin.id)") }
            try await kernelPlugin.onReady(kernel: kernel)
        }
    }

    // MARK: - Plugin Enable State

    /// 判断插件最终是否启用（结合策略 + 用户覆盖）。
    public func isPluginEnabled(_ plugin: any SuperPlugin) -> Bool {
        let metadata = type(of: plugin).metadata
        return Self.effectiveEnabled(
            policy: metadata.policy,
            override: stateStore.override(for: plugin.id)
        )
    }

    /// 获取用户对某插件的启用/禁用覆盖值。
    public func override(for pluginID: String) -> Bool? {
        stateStore.override(for: pluginID)
    }

    /// 设置用户对某插件的启用/禁用覆盖值。
    public func setOverride(_ enabled: Bool, for pluginID: String) {
        stateStore.setOverride(enabled, for: pluginID)
    }

    /// 清除用户对某插件的覆盖，回落到策略默认值。
    public func clearOverride(for pluginID: String) {
        stateStore.clearOverride(for: pluginID)
    }

    /// 解析插件的最终启用状态。
    ///
    /// - Parameters:
    ///   - policy: 插件策略。
    ///   - override: 用户覆盖值（可能为 nil）。
    /// - Returns: 最终是否启用。
    static func effectiveEnabled(policy: PluginPolicy, override: Bool?) -> Bool {
        switch policy {
        case .alwaysOn:
            true
        case .disabled:
            false
        case .optOut:
            override ?? true
        case .optIn:
            override ?? false
        }
    }

    /// 获取所有已注册的插件实例（仅已启用的）。
    public var enabledPlugins: [any SuperPlugin] {
        orderedPluginKeys.compactMap { pluginRegistry[$0] }.filter { isPluginEnabled($0) }
    }

    /// 获取所有已注册的插件实例（包含未启用的）。
    public var allPlugins: [any SuperPlugin] {
        orderedPluginKeys.compactMap { pluginRegistry[$0] }
    }

    /// 根据插件 ID 查找插件。
    ///
    /// - Parameter id: 插件 ID。
    /// - Returns: 找到的插件或 nil。
    public func plugin(by id: String) -> (any SuperPlugin)? {
        pluginRegistry.values.first { $0.id == id }
    }

    // MARK: - Private

    /// 注册单个插件到内部注册表。
    private func register(_ plugin: any SuperPlugin) {
        let id = plugin.id

        // 重复检测
        guard !usedIDs.contains(id) else {
            let pluginType = String(describing: type(of: plugin))
            os_log(.error, "\(Self.t)❌ Duplicate plugin id '\(id)' in \(pluginType)")
            assertionFailure("Duplicate plugin id: \(id)")
            return
        }

        guard !id.isEmpty else {
            os_log(.error, "\(Self.t)❌ Plugin with empty ID: \(String(describing: type(of: plugin)))")
            assertionFailure("Plugin has empty ID")
            return
        }

        usedIDs.insert(id)

        // 使用版本化类型名称作为键，避免同类型多次注册时的冲突
        let key = String(describing: type(of: plugin))
        let versionedKey = makeVersionedKey(base: key, id: id)
        pluginRegistry[versionedKey] = plugin
        orderedPluginKeys.append(versionedKey)
    }

    /// 生成版本化键，避免名字冲突。
    private func makeVersionedKey(base: String, id: String) -> String {
        // 如果 base 键尚未使用，直接返回
        if pluginRegistry[base] == nil {
            return base
        }
        // 否则使用 ID 作为后缀
        return "\(base)-\(id)"
    }

    /// 获取日志前缀（静态，方便在非隔离上下文中使用）。
    nonisolated private static var t: String {
        let author = "BuiltinPluginManager"
        return "[KT] | \(Self.emoji) \(author.padding(toLength: 22, withPad: " ", startingAt: 0)) | "
    }
}
