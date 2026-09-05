import Foundation
import MagicPlayMan
import ProviderPlayback

/// AudioProgress 能够发出的最小播放命令边界。
///
/// 这是插件面向 ViewModel 暴露的能力；ViewModel 不依赖 Kernel、
/// `PlaybackProviding` 或 `MagicPlayMan` 具体类型。Adapter 在
/// `AudioProgressPlugin` 的 onReady/onEnable 阶段由内核 Provider 组装。
@MainActor
protocol AudioProgressPlaybackCapability: AnyObject {
    /// 当前播放资源 URL。
    var currentAsset: URL? { get }

    /// 当前播放状态。
    var state: MagicPlayState { get }

    /// 当前播放进度（秒）。
    var currentTime: TimeInterval { get }

    /// 播放指定 URL（可指定起始时间，不自动开始）。
    func play(_ url: URL, autoPlay: Bool, startTime: TimeInterval, reason: String) async

    /// 设置喜欢状态。
    func setLike(_ liked: Bool, reason: String)
}

/// 将内核的 `PlaybackProviding` 适配成 AudioProgress 的播放能力。
@MainActor
final class AudioProgressPlaybackCapabilityAdapter: AudioProgressPlaybackCapability {
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

    func setLike(_ liked: Bool, reason: String) {
        playback.setLike(liked, reason: reason)
    }
}
