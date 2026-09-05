import Foundation
import ProviderPlayback
import SwiftUI

/// 播放进度的显示状态；外部播放变化只通过 Observer 写入。
@MainActor
final class PlaybackProgressViewModel: ObservableObject {
    @Published private(set) var currentTime: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0

    private weak var playback: (any PlaybackProviding)?

    init(playback: (any PlaybackProviding)?) {
        self.playback = playback
        sync(from: playback)
    }

    func handlePlaybackEvent(_ event: PlaybackProvidingEvent) {
        switch event {
        case .timeChanged(let currentTime, _):
            self.currentTime = currentTime
        case .durationChanged(let duration):
            self.duration = duration
        case .assetChanged:
            sync(from: playback)
        default:
            break
        }
    }

    func seek(to time: TimeInterval) {
        let normalized = max(time.isFinite ? time : 0, 0)
        currentTime = normalized
        playback?.seek(toTime: normalized)
    }

    private func sync(from playback: (any PlaybackProviding)?) {
        currentTime = playback?.currentTime ?? 0
        duration = playback?.duration ?? 0
    }
}
