import CisumUI
import Foundation

/// 内核感知的插件协议。
///
/// 继承自 `SuperPlugin`，新增内核生命周期方法。注意：与 `SuperPlugin` 一样，
/// 此协议本身不标注 `@MainActor`（否则 `actor` 类型的插件无法遵循），
/// 而是把两个生命周期方法单独标注为 `@MainActor`。
///
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
///     }
/// }
/// ```
public protocol CisumKernelPlugin: SuperPlugin {
    /// 阶段 1: 注册核心服务。
    ///
    /// 在此方法中调用 `kernel.registerXxx()` 注册 Provider 实现。
    /// 此阶段结束后内核进行服务校验。
    @MainActor func onBoot(kernel: CisumKernel) async throws

    /// 阶段 2: 所有服务就绪后执行异步初始化。
    ///
    /// 在此方法中执行依赖其他服务的初始化逻辑。
    /// 此阶段在所有插件的 `onBoot` 完成后统一调用。
    @MainActor func onReady(kernel: CisumKernel) async throws

    /// 阶段 3: 插件卸载或内核停止时逆序调用，撤回运行期贡献。
    ///
    /// 在此方法中注销插件在 `onBoot` / `onReady` 期间注册的 Provider，
    /// 或清理插件持有的静态桥接引用。内核会在启动失败回滚、`shutdown()`、
    /// 以及未来单插件卸载时调用。默认空实现。
    @MainActor func onShutdown(kernel: CisumKernel) async throws

    /// 阶段 4: 插件从内核注销前调用，撤回注册期贡献。
    ///
    /// 用于撤回不依赖运行状态的目录型贡献。在所有 `onShutdown` 完成后
    /// 统一逆序调用。默认空实现。
    @MainActor func onUnregister(kernel: CisumKernel) async throws
}

// MARK: - Default Implementations

extension CisumKernelPlugin {
    /// 默认 onBoot: 无操作。
    @MainActor public func onBoot(kernel: CisumKernel) async throws {}

    /// 默认 onReady: 无操作。
    @MainActor public func onReady(kernel: CisumKernel) async throws {}

    /// 默认 onShutdown: 无操作。
    @MainActor public func onShutdown(kernel: CisumKernel) async throws {}

    /// 默认 onUnregister: 无操作。
    @MainActor public func onUnregister(kernel: CisumKernel) async throws {}
}
