import Foundation
import ProviderPlayback

@MainActor
final class LikeButtonObserver {
    private weak var viewModel: LikeButtonViewModel?
    private var handle: (any PlaybackProvidingObserverHandle)?

    init(playback: any PlaybackProviding, viewModel: LikeButtonViewModel) {
        self.viewModel = viewModel
        handle = playback.addObserver { [weak self] event in
            self?.viewModel?.handlePlaybackEvent(event)
        }
    }

    func cancel() {
        handle?.cancel()
        handle = nil
    }
}
