import ProviderTheme

@MainActor
final class ThemeProvidingObserver {
    private weak var viewModel: ThemeSettingsViewModel?
    private var handle: (any ThemeProvidingObserverHandle)?

    init(provider: any ThemeProviding, viewModel: ThemeSettingsViewModel) {
        self.viewModel = viewModel
        // Initial sync：先同步当前快照，再安装监听，避免丢失监听安装前的状态。
        viewModel.handle(.providerChanged(.themesChanged(provider.allThemeContributions)))
        viewModel.handle(.providerChanged(.selectionChanged(provider.selectedThemeID)))
        handle = provider.addObserver { [weak self] event in
            self?.viewModel?.handle(.providerChanged(event))
        }
    }

    func cancel() {
        handle?.cancel()
        handle = nil
    }
}
