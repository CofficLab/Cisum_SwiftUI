import CisumUI
import PluginThemeForest
import SwiftUI

actor ThemeForestPlugin: SuperPlugin {
    static let shared = ThemeForestPlugin()
    static var shouldRegister: Bool { true }
    static var order: Int { 150 }

    private nonisolated var theme: ForestTheme { ForestTheme() }

    nonisolated var title: String { theme.displayName }
    nonisolated var description: String { theme.description }
    nonisolated var iconName: String { theme.iconName }

    @MainActor
    func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: ForestTheme())]
    }
}
