import Foundation
import MagicPlayMan
import ProviderPlayback
import MagicKit

/// AudioControl 能够发出的最小播放命令边界。
///
/// 这是插件面向 ViewModel 暴露的能力；ViewModel 不依赖 Kernel、
/// `PlaybackProviding` 或 `MagicPlayMan` 具体类型。Adapter 在
/// `AudioControlPlugin` 的 onReady/onEnable 阶段由内核 Provider 组装。
@MainActor
protocol AudioControlPlaybackCapability: AnyObject {
    /// 当前播放资源 URL。
    var currentURL: URL? { get }

    /// 当前播放模式（顺序/随机/单曲循环等）。
    var playMode: MagicPlayMode { get }

    /// 播放指定 URL（自动开始播放）。
    func play(_ url: URL) async

    /// 完全卸载当前资源并恢复空闲状态。
    func reset() async
}

/// 将内核的 `PlaybackProviding` 适配成 AudioControl 的播放能力。
@MainActor
final class AudioControlPlaybackCapabilityAdapter: AudioControlPlaybackCapability, SuperLog {
    nonisolated static let verbose = false

    private let playback: any PlaybackProviding

    init(playback: any PlaybackProviding) {
        self.playback = playback
    }

    var currentURL: URL? { playback.currentURL }

    var playMode: MagicPlayMode { playback.playMode }

    func play(_ url: URL) async {
        await playback.play(url)
    }

    func reset() async {
        await playback.reset()
    }
}
