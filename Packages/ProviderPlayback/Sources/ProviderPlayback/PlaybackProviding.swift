import Foundation
import MagicPlayMan

/// 播放服务能力协议。
///
/// 直接复用 `MagicPlayMan` 的真实类型（`PlaybackState` / `MagicPlayMode`），
/// 避免维护一套并行的播放状态枚举。具体实现由 `MagicPlayMan` 在 Factory
/// 注册时提供；插件视图中仍可通过 `@EnvironmentObject MagicPlayMan` 直接
/// 访问完整引擎 API，而新布局视图通过此协议消费。
///
/// ## 使用示例
///
/// ```swift
/// kernel.playback?.toggle()
/// let isPlaying = kernel.playback?.isPlaying ?? false
/// kernel.playback?.setPlayMode(.shuffle)
/// ```
@MainActor
public protocol PlaybackProviding: AnyObject, ObservableObject {
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

    /// 循环切换播放模式。
    func togglePlayMode()
}
