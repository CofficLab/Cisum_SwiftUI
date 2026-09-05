import Foundation
import MagicPlayMan
import ProviderPlayback

/// BookPlayMode 需要的最小播放能力边界。
///
/// 插件在目标场景激活时恢复/同步播放模式；ViewModel 不直接持有
/// `PlaybackProviding` 或 `MagicPlayMan` 具体类型。
@MainActor
protocol BookPlayModePlaybackCapability: AnyObject {
    /// 当前播放模式。
    var playMode: MagicPlayMode { get }

    /// 设置播放模式。
    func setPlayMode(_ mode: MagicPlayMode)
}

/// 将内核的 `PlaybackProviding` 适配成 BookPlayMode 的播放能力。
@MainActor
final class BookPlayModePlaybackCapabilityAdapter: BookPlayModePlaybackCapability {
    private let playback: any PlaybackProviding

    init(playback: any PlaybackProviding) {
        self.playback = playback
    }

    var playMode: MagicPlayMode { playback.playMode }

    func setPlayMode(_ mode: MagicPlayMode) {
        playback.setPlayMode(mode)
    }
}
