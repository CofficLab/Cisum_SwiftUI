import CisumUI
import PluginThemeMidnight
import SwiftUI

actor ThemeMidnightPlugin: SuperPlugin {
    static let shared = ThemeMidnightPlugin()
    static var shouldRegister: Bool { true }
    static var order: Int { 160 }

    private nonisolated var theme: MidnightTheme { MidnightTheme() }

    nonisolated var title: String { theme.displayName }
    nonisolated var description: String { theme.description }
    nonisolated var iconName: String { theme.iconName }

    @MainActor
    func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: MidnightTheme())]
    }
}
