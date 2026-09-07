import Foundation
import OSLog
import ProviderPlayback
import MagicKit

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
final class AudioPlaybackCapabilityAdapter: AudioPlaybackCapability, SuperLog {
    nonisolated static let verbose = true

    private let playback: any PlaybackProviding

    init(playback: any PlaybackProviding) {
        self.playback = playback
        os_log("[AudioDBPlayback] capability adapter initialized")
    }

    func play(_ url: URL) async {
        os_log("[AudioDBPlayback] capability adapter forwarding play: %{public}s", url.path)
        await playback.play(url)
        os_log("[AudioDBPlayback] capability adapter play completed: %{public}s", url.lastPathComponent)
    }

    func reset() async {
        os_log("[AudioDBPlayback] capability adapter forwarding reset")
        await playback.reset()
        os_log("[AudioDBPlayback] capability adapter reset completed")
    }
}
