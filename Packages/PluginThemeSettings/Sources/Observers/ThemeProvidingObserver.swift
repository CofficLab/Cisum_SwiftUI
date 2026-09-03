import ProviderTheme

@MainActor
final class ThemeProvidingObserver {
    private weak var viewModel: ThemeSettingsViewModel?
    private var handle: (any ThemeProvidingObserverHandle)?

    init(provider: any ThemeProviding, viewModel: ThemeSettingsViewModel) {
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
