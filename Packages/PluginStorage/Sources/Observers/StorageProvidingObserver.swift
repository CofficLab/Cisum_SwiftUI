import ProviderStorage

@MainActor
final class StorageProvidingObserver {
    private weak var viewModel: StorageSettingsViewModel?
    private var handle: (any StorageProvidingObserverHandle)?

    init(provider: any StorageProviding, viewModel: StorageSettingsViewModel) {
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
