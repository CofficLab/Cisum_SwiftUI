import ProviderPlayback

@MainActor
final class ControlButtonsObserver {
    private weak var viewModel: ControlButtonsViewModel?
    private var handle: (any PlaybackProvidingObserverHandle)?

    init(playback: any PlaybackProviding, viewModel: ControlButtonsViewModel) {
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
