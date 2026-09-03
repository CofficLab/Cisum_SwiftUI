import Combine
import CisumUIComponents
import Foundation
import ProviderTheme

@MainActor
final class ThemeSettingsViewModel: ObservableObject {
    @Published private(set) var themes: [LumiUIThemeContribution] = []
    @Published private(set) var currentThemeID = ""

    private weak var theme: (any ThemeProviding)?
    private var observer: ThemeProvidingObserver?

    init(theme: (any ThemeProviding)?) {
        attach(to: theme)
    }

    func attach(to theme: (any ThemeProviding)?) {
        observer?.cancel()
        observer = nil
        self.theme = theme
        refresh()

        guard let theme else { return }
        observer = ThemeProvidingObserver(provider: theme, viewModel: self)
    }

    func selectTheme(_ themeID: String) {
        theme?.selectTheme(themeID)
    }

    func handle(_ event: ThemeSettingsPluginEvent) {
        switch event {
        case .providerChanged:
            refresh()
        }
    }

    private func refresh() {
        themes = theme?.allThemeContributions ?? []
        currentThemeID = theme?.selectedThemeID ?? ""
    }
}
