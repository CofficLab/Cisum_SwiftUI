import ProviderScene

@MainActor
final class SceneProvidingObserver {
    private weak var viewModel: SceneSettingsViewModel?
    private var handle: (any SceneProvidingObserverHandle)?

    init(provider: any SceneProviding, viewModel: SceneSettingsViewModel) {
        self.viewModel = viewModel
        // Initial sync：先同步当前快照，再安装监听，避免丢失监听安装前的状态。
        viewModel.handle(.providerChanged(.selectionChanged(scene: provider.currentScene)))
        handle = provider.addObserver { [weak self] event in
            self?.viewModel?.handle(.providerChanged(event))
        }
    }

    func cancel() {
        handle?.cancel()
        handle = nil
    }
}
