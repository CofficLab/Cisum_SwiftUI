import Combine
import MagicPlayMan

@MainActor
final class ControlButtonsViewModel: ObservableObject {
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
