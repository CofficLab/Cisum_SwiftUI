import Combine
import Foundation
import LumiUI
import MagicKit

@MainActor
final class ThemeSettingsViewModel: ObservableObject, SuperLog {
    nonisolated static let verbose = false

    @Published private(set) var themes: [LumiUIThemeContribution] = []
    @Published private(set) var currentThemeID = ""

    private let capability: (any ThemeSettingsCapability)?

    init(capability: (any ThemeSettingsCapability)?) {
        self.capability = capability
        refresh()
    }

    func selectTheme(_ themeID: String) {
        capability?.selectTheme(themeID)
    }

    func handleProviderChanged() {
        refresh()
    }

    private func refresh() {
        themes = capability?.allThemeContributions ?? []
        currentThemeID = capability?.selectedThemeID ?? ""
    }
}
