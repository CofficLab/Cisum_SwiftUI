import KernelCore
import MagicPlayMan
import ProviderPlayback

/// 播放插件：负责创建并持有 `MagicPlayMan` 播放引擎，将其作为
/// `PlaybackProviding` 注入内核，使播放能力成为插件化的基础设施。
///
/// 原先由 `FactoryCisum` 直接创建 `MagicPlayMan` 并 `registerPlayback`，
/// 现收拢到本插件的 `onBoot`：插件持有播放引擎生命周期，内核通过
/// `kernel.playback` 解析到 `MagicPlayMan` 实例（UI 层仍可
/// `as? MagicPlayMan` 注入 `@EnvironmentObject`）。
public actor PluginPlayBack: SuperPlugin {
    public static let shared = PluginPlayBack()
    public static let metadata = PluginMetadata(
        displayName: "播放",
        description: "播放引擎与播放状态管理。",
        iconName: "play.circle",
        order: 5,
        policy: .alwaysOn,
        category: .system
    )

    /// 持有的播放引擎；onBoot 时创建并注册为 `PlaybackProviding`。
    nonisolated(unsafe) public private(set) var magicPlayMan: MagicPlayMan?

    public init() {}

    @MainActor
    public func onBoot(kernel: CisumKernel) async throws {
        let player = MagicPlayMan()
        magicPlayMan = player
        kernel.registerPlayback(player)
    }

    @MainActor
    public func onShutdown(kernel: CisumKernel) async throws {
        magicPlayMan = nil
    }
}
