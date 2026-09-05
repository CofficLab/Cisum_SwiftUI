import Foundation
import MagicPlayMan
import ProviderPlayback

/// ControlButtons 能够发出的最小播放命令边界。
///
/// 这是插件面向 ViewModel 暴露的能力；ViewModel 不依赖 Kernel、
/// `PlaybackProviding` 或 `MagicPlayMan` 具体类型。Adapter 在
/// `ControlButtonsPlugin` 的 onReady 阶段由内核 Provider 组装。
@MainActor
protocol ControlButtonsPlaybackCapability: AnyObject {
    /// 当前是否正在播放。
    var isPlaying: Bool { get }

    /// 当前播放模式（顺序/随机/单曲循环等）。
    var playMode: MagicPlayMode { get }

    /// 播放/暂停切换。
    func toggle()

    /// 上一曲。
    func previous()

    /// 下一曲。
    func next()

    /// 循环切换播放模式。
    func togglePlayMode()
}

/// 将内核的 `PlaybackProviding` 适配成 ControlButtons 的播放能力。
@MainActor
final class ControlButtonsPlaybackCapabilityAdapter: ControlButtonsPlaybackCapability {
    private let playback: any PlaybackProviding

    init(playback: any PlaybackProviding) {
        self.playback = playback
    }

    var isPlaying: Bool { playback.isPlaying }

    var playMode: MagicPlayMode { playback.playMode }

    func toggle() { playback.toggle() }

    func previous() { playback.previous() }

    func next() { playback.next() }

    func togglePlayMode() { playback.togglePlayMode() }
}
