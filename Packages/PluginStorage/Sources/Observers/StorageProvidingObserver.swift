import ProviderStorage

@MainActor
final class StorageProvidingObserver {
    private weak var viewModel: StorageSettingsViewModel?
    private var handle: (any StorageProvidingObserverHandle)?

    init(provider: any StorageProviding, viewModel: StorageSettingsViewModel) {
        self.viewModel = viewModel
        // Initial sync：先同步当前快照，再安装监听，避免丢失监听安装前的状态。
        viewModel.handle(.providerChanged(.locationChanged(provider.currentStorageLocation)))
        viewModel.handle(.providerChanged(.storageAvailabilityChanged))
        handle = provider.addObserver { [weak self] event in
            self?.viewModel?.handle(.providerChanged(event))
        }
    }

    func cancel() {
        handle?.cancel()
        handle = nil
    }
}
