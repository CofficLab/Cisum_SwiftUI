import ProviderScene

@MainActor
final class SceneProvidingObserver {
    private weak var viewModel: SceneSettingsViewModel?
    private var handle: (any SceneProvidingObserverHandle)?

    init(provider: any SceneProviding, viewModel: SceneSettingsViewModel) {
        self.viewModel = viewModel
        handle = provider.addObserver { [weak self] event in
            self?.viewModel?.handle(.providerChanged(event))
        }
    }

    func cancel() {
        handle?.cancel()
        handle = nil
    }
}
