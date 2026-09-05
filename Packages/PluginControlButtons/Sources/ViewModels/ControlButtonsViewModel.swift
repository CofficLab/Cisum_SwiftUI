import Combine
import MagicPlayMan
import ProviderPlayback

@MainActor
final class ControlButtonsViewModel: ObservableObject {
    @Published private(set) var isPlaying = false
    @Published private(set) var playMode: MagicPlayMode = .sequence

    private weak var playback: (any PlaybackProviding)?

    func bind(playback: any PlaybackProviding) {
        self.playback = playback
        isPlaying = playback.isPlaying
        playMode = playback.playMode
    }

    func handlePlaybackEvent(_ event: PlaybackProvidingEvent) {
        switch event {
        case .stateChanged(let state): isPlaying = state == .playing
        case .playModeChanged(let mode): playMode = mode
        default: break
        }
    }

    func toggle() { playback?.toggle() }
    func previous() { playback?.previous() }
    func next() { playback?.next() }
    func togglePlayMode() { playback?.togglePlayMode() }
}
