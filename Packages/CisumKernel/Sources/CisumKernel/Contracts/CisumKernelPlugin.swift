import CisumUI
import Foundation

/// 内核感知的插件协议。
///
/// 继承自 `SuperPlugin`，新增内核生命周期方法。
/// 插件可以通过实现此协议来参与内核的服务注册和异步初始化流程。
///
/// ## 与 SuperPlugin 的关系
///
/// - `SuperPlugin` (CisumUI) 定义插件的 UI 贡献点与基本生命周期 (`onRegister` / `onEnable`)。
/// - `CisumKernelPlugin` 在此之上添加内核两阶段启动:
///   - `onBoot(kernel:)` — 服务注册阶段
///   - `onReady(kernel:)` — 依赖服务的异步初始化阶段
///
/// 不直接实现 `CisumKernelPlugin` 的插件仍可通过 `SuperPlugin` 正常工作，
/// 只是无法在内核启动阶段注入服务。
///
/// ## 使用示例
///
/// ```swift
/// actor AudioPlugin: CisumKernelPlugin {
///     static let shared = AudioPlugin()
///     static let metadata = PluginMetadata(displayName: "Audio", ...)
///
///     func onBoot(kernel: CisumKernel) async throws {
///         kernel.registerPlayback(myPlaybackService)
///     }
///
///     func onReady(kernel: CisumKernel) async throws {
///         // 此时所有服务已就绪
///         await myPlaybackService.loadPlaylist()
///     }
/// }
/// ```
@MainActor
public protocol CisumKernelPlugin: SuperPlugin {
    /// 阶段 1: 注册核心服务。
    ///
    /// 在此方法中调用 `kernel.registerXxx()` 注册 Provider 实现。
    /// 此阶段结束后内核进行服务校验。
    func onBoot(kernel: CisumKernel) async throws

    /// 阶段 2: 所有服务就绪后执行异步初始化。
    ///
    /// 在此方法中执行依赖其他服务的初始化逻辑。
    /// 此阶段在所有插件的 `onBoot` 完成后统一调用。
    func onReady(kernel: CisumKernel) async throws
}

// MARK: - Default Implementations

extension CisumKernelPlugin {
    /// 默认 onBoot: 无操作。
    public func onBoot(kernel: CisumKernel) async throws {}

    /// 默认 onReady: 无操作。
    public func onReady(kernel: CisumKernel) async throws {}
}
