import Combine
import MagicPlayMan
import MagicKit

@MainActor
final class ControlButtonsViewModel: ObservableObject, SuperLog {
    nonisolated static let verbose = false

    @Published private(set) var isPlaying = false
    @Published private(set) var playMode: MagicPlayMode = .sequence

    private let playbackCapability: (any ControlButtonsPlaybackCapability)?

    init(playbackCapability: (any ControlButtonsPlaybackCapability)?) {
        self.playbackCapability = playbackCapability
        if let playbackCapability {
            isPlaying = playbackCapability.isPlaying
            playMode = playbackCapability.playMode
        }
    }

    func applyStateChanged(_ state: PlaybackState) {
        isPlaying = state == .playing
    }

    func applyPlayModeChanged(_ mode: MagicPlayMode) {
        playMode = mode
    }

    func toggle() { playbackCapability?.toggle() }
    func previous() { playbackCapability?.previous() }
    func next() { playbackCapability?.next() }
    func togglePlayMode() { playbackCapability?.togglePlayMode() }
}
