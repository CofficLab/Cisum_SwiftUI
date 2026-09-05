import Foundation
import ProviderPlayback

/// AudioDB 能够发出的播放能力。
///
/// 这是插件面向 ViewModel 暴露的最小命令边界；ViewModel 不依赖 Kernel、
/// `PlaybackProviding` 或播放事件订阅。
@MainActor
protocol AudioPlaybackCapability: AnyObject {
    func play(_ url: URL) async
    func reset() async
}

/// 将内核的 `PlaybackProviding` 适配成 AudioDB 的播放能力。
@MainActor
final class AudioPlaybackCapabilityAdapter: AudioPlaybackCapability {
    private let playback: any PlaybackProviding

    init(playback: any PlaybackProviding) {
        self.playback = playback
    }

    func play(_ url: URL) async {
        await playback.play(url)
    }

    func reset() async {
        await playback.reset()
    }
}
