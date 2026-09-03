import KernelCore
import Foundation

/// 插件启停控制协议（对齐 Lumi `ProviderPluginControl/PluginControlling`）。
///
/// 设置中的插件管理页通过它驱动运行期启停 + 贡献重建 + 持久化。
@MainActor
public protocol PluginControlling: AnyObject {
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

/// 直接驱动 `BuiltinPluginManager` 的插件控制实现。
///
/// 控制动作连接到真实生命周期（写入用户覆盖 + 重建贡献 + 通知），
/// 并保留最近一次错误供设置页展示。
@MainActor
public final class DefaultPluginControlling: PluginControlling {
    public private(set) var lastErrorDescription: String?
    private let manager: BuiltinPluginManager
    private weak var kernel: CisumKernel?

    public init(manager: BuiltinPluginManager, kernel: CisumKernel) {
        self.manager = manager
        self.kernel = kernel
    }

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
