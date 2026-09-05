import ProviderPlayback

@MainActor
final class ControlButtonsObserver {
    private weak var viewModel: ControlButtonsViewModel?
    private var handle: (any PlaybackProvidingObserverHandle)?

    init(playback: any PlaybackProviding, viewModel: ControlButtonsViewModel) {
        self.viewModel = viewModel
        handle = playback.addObserver { [weak self] event in
            guard let self else { return }
            switch event {
            case .stateChanged(let state):
                self.viewModel?.applyStateChanged(state)
            case .playModeChanged(let mode):
                self.viewModel?.applyPlayModeChanged(mode)
            default: break
            }
        }
    }

    func cancel() {
        handle?.cancel()
        handle = nil
    }
}
