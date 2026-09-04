import KernelCore
import MagicPlayMan
import ProviderPlayback
import ProviderStorage

/// 播放插件：负责创建并持有 `MagicPlayMan` 播放引擎，将其作为
/// `PlaybackProviding` 注入内核，并维护当前播放文件的磁盘持久化与恢复。
///
/// 原先由 `FactoryCisum` 直接创建 `MagicPlayMan` 并 `registerPlayback`，
/// 现收拢到本插件的 `onBoot`：插件持有播放引擎生命周期，内核通过
/// `kernel.playback` 解析到 `MagicPlayMan` 实例（UI 层仍可
/// `as? MagicPlayMan` 注入 `@EnvironmentObject`）。
///
/// ## 播放文件持久化
/// onBoot 时从 `kernel.storage` 解析数据库根目录，创建 `PlaybackStateStore`，
/// 读取上次播放文件并恢复（`autoPlay: false`，仅加载不自动播放）；随后订阅
/// 播放引擎的 `.assetChanged` 事件，把当前播放文件写入
/// `<databaseRoot>/PluginPlayBack/current-playback.plist`。该功能仅有此插件维护。
public actor PluginPlayBack: SuperPlugin {
    public static let shared = PluginPlayBack()
    public static let metadata = PluginMetadata(
        displayName: "播放",
        description: "播放引擎与播放状态管理。",
        iconName: "play.circle",
        order: 12,
        policy: .disabled,
        category: .system
    )

    /// 持有的播放引擎；onBoot 时创建并注册为 `PlaybackProviding`。
    nonisolated(unsafe) public private(set) var magicPlayMan: MagicPlayMan?

    /// 当前播放文件的磁盘存储（onBoot 时从 kernel.storage 创建）。
    nonisolated(unsafe) private var stateStore: PlaybackStateStore?

    /// 播放状态变化监听句柄（记录当前文件到磁盘）。
    nonisolated(unsafe) private var observerHandle: (any PlaybackProvidingObserverHandle)?

    public init() {}

    @MainActor
    public func onBoot(kernel: CisumKernel) async throws {
        let player = MagicPlayMan()
        magicPlayMan = player
        kernel.registerPlayback(player)

        // 持久化恢复 + 记录（order 12 在 StoragePlugin 之后，kernel.storage 已可用）
        guard let storage = kernel.storage else { return }
        let store = PlaybackStateStore(rootDirectory: storage.databaseRoot)
        stateStore = store

        // 恢复上次播放文件（仅加载，不自动播放）
        if let lastURL = store.loadCurrentFile() {
            await player.play(lastURL, autoPlay: false, reason: "PluginPlayBack.restore")
        }

        // 监听后续文件变化，记录到磁盘
        observerHandle = player.addObserver { [weak self] event in
            guard case .assetChanged(let url) = event else { return }
            self?.stateStore?.saveCurrentFile(url)
        }
    }

    @MainActor
    public func onShutdown(kernel: CisumKernel) async throws {
        observerHandle?.cancel()
        observerHandle = nil
        stateStore = nil
        magicPlayMan = nil
    }
}
