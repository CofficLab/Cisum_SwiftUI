import Foundation
import MagicPlayMan
import ProviderPlayback

/// BookProgress 能够发出的最小播放命令边界。
///
/// 这是插件面向 ViewModel 暴露的能力；ViewModel 不依赖 Kernel、
/// `PlaybackProviding` 或 `MagicPlayMan` 具体类型。Adapter 在
/// `BookProgressPlugin` 的 onReady/onEnable 阶段由内核 Provider 组装。
@MainActor
protocol BookProgressPlaybackCapability: AnyObject {
    /// 当前播放资源 URL。
    var currentAsset: URL? { get }

    /// 当前播放状态。
    var state: MagicPlayState { get }

    /// 当前播放进度（秒）。
    var currentTime: TimeInterval { get }

    /// 播放指定 URL（可指定起始时间，不自动开始）。
    func play(_ url: URL, autoPlay: Bool, startTime: TimeInterval, reason: String) async
}

/// 将内核的 `PlaybackProviding` 适配成 BookProgress 的播放能力。
@MainActor
final class BookProgressPlaybackCapabilityAdapter: BookProgressPlaybackCapability {
    private let playback: any PlaybackProviding

    init(playback: any PlaybackProviding) {
        self.playback = playback
    }

    var currentAsset: URL? { playback.currentURL }

    var state: MagicPlayState { playback.state }

    var currentTime: TimeInterval { playback.currentTime }

    func play(_ url: URL, autoPlay: Bool, startTime: TimeInterval, reason: String) async {
        await playback.play(url, autoPlay: autoPlay, startTime: startTime, reason: reason)
    }
}
