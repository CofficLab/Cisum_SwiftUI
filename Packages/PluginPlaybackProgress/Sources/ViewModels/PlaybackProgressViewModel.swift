import Foundation
import SwiftUI

/// 播放进度的显示状态；外部播放变化只通过 Observer 写入。
@MainActor
final class PlaybackProgressViewModel: ObservableObject {
    @Published private(set) var currentTime: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0

    private let playbackCapability: (any PlaybackProgressCapability)?

    init(playbackCapability: (any PlaybackProgressCapability)?) {
        self.playbackCapability = playbackCapability
        sync()
    }

    func handlePlaybackEvent(_ event: PlaybackProvidingEvent) {
        switch event {
        case .timeChanged(let currentTime, _):
            self.currentTime = currentTime
        case .durationChanged(let duration):
            self.duration = duration
        case .assetChanged:
            sync()
        default:
            break
        }
    }

    func seek(to time: TimeInterval) {
        let normalized = max(time.isFinite ? time : 0, 0)
        currentTime = normalized
        playbackCapability?.seek(toTime: normalized)
    }

    private func sync() {
        currentTime = playbackCapability?.currentTime ?? 0
        duration = playbackCapability?.duration ?? 0
    }
}
