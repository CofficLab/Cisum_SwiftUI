import ProviderPlayback

@MainActor
final class OpenButtonObserver {
    private weak var viewModel: OpenButtonViewModel?
    private var handle: (any PlaybackProvidingObserverHandle)?

    init(playback: any PlaybackProviding, viewModel: OpenButtonViewModel) {
        self.viewModel = viewModel
        viewModel.bind(playback: playback)
        handle = playback.addObserver { [weak self] event in
            self?.viewModel?.handlePlaybackEvent(event)
        }
    }

    func cancel() {
        handle?.cancel()
        handle = nil
    }
}
