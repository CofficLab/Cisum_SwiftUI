import Foundation
import MagicPlayMan

@MainActor
public enum PlaybackProvidingEvent {
    case stateChanged(PlaybackState)
    case assetChanged(URL?)
    case timeChanged(currentTime: TimeInterval, progress: Double)
    case durationChanged(TimeInterval)
    case playModeChanged(MagicPlayMode)
    case likedAssetsChanged(Set<URL>)
    case likeStatusChanged(asset: URL, isLiked: Bool)
    case previousRequested(URL)
    case nextRequested(URL)
}

@MainActor
public protocol PlaybackProvidingObserverHandle: AnyObject {
    func cancel()
}

/// 播放服务能力协议。
///
/// 直接复用 `MagicPlayMan` 的真实类型（`PlaybackState` / `MagicPlayMode`），
/// 避免维护一套并行的播放状态枚举。具体实现由 `MagicPlayMan` 在 Factory
/// 注册时提供；插件视图中仍可通过 `@EnvironmentObject MagicPlayMan` 直接
/// 访问完整引擎 API，而新布局视图通过此协议消费。
///
/// 状态变更的唯一对外通知方式是 `addObserver`（`PlaybackProvidingEvent`），
/// 协议本身不依赖 `ObservableObject`。
///
/// ## 使用示例
///
/// ```swift
/// kernel.playback?.toggle()
/// let isPlaying = kernel.playback?.isPlaying ?? false
/// kernel.playback?.setPlayMode(.shuffle)
/// ```
@MainActor
public protocol PlaybackProviding: AnyObject {
    /// 底层播放状态（idle/loading/playing/paused/...）。
    var state: PlaybackState { get }

    /// 当前播放资源的 URL。
    var currentURL: URL? { get }

    /// 当前播放时间（秒）。
    var currentTime: TimeInterval { get }

    /// 总时长（秒）。
    var duration: TimeInterval { get }

    /// 播放进度 (0.0 ~ 1.0)。
    var progress: Double { get }

    /// 当前播放模式。
    var playMode: MagicPlayMode { get }

    /// 已点赞的资源集合。
    var likedAssets: Set<URL> { get }

    /// 是否正在播放（便捷判断）。
    var isPlaying: Bool { get }

    /// 是否已加载资源。
    var hasAsset: Bool { get }

    /// 播放指定 URL。
    func play(_ url: URL) async

    /// 播放指定 URL，并可从保存的时间点开始。
    func play(_ url: URL, startTime: TimeInterval?) async

    /// 暂停。
    func pause()

    /// 依据当前状态在播放/暂停间切换。
    func toggle()

    /// 跳转到指定进度 (0.0 ~ 1.0)。
    func seek(toProgress progress: Double)

    /// 跳转到指定时间点（秒）。
    func seek(toTime time: TimeInterval)

    /// 下一首。
    func next()

    /// 上一首。
    func previous()

    /// 设置播放模式。
    func setPlayMode(_ mode: MagicPlayMode)

    /// 切换当前资源的喜欢状态。
    func toggleCurrentLike()

    /// 完全卸载当前资源并恢复空闲状态。
    func reset() async

    /// 循环切换播放模式。
    func togglePlayMode()

    @discardableResult
    func addObserver(_ callback: @escaping (PlaybackProvidingEvent) -> Void) -> any PlaybackProvidingObserverHandle
}

public extension PlaybackProviding {
    func play(_ url: URL, startTime: TimeInterval?) async {
        await play(url)
    }

    func reset() async {}

    @discardableResult
    func addObserver(_ callback: @escaping (PlaybackProvidingEvent) -> Void) -> any PlaybackProvidingObserverHandle {
        NoopPlaybackProvidingObserverHandle()
    }
}

@MainActor
public final class NoopPlaybackProvidingObserverHandle: PlaybackProvidingObserverHandle {
    public init() {}
    public func cancel() {}
}
