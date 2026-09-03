import Combine
import CisumUIComponents
import Foundation
import ProviderTheme

@MainActor
final class ThemeSettingsViewModel: ObservableObject {
    @Published private(set) var themes: [LumiUIThemeContribution] = []
    @Published private(set) var currentThemeID = ""

    private weak var theme: (any ThemeProviding)?

    init(theme: (any ThemeProviding)?) {
        self.theme = theme
        refresh()
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
