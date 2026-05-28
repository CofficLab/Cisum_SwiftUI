import CisumUI
import PluginThemeSunset
import SwiftUI

actor ThemeSunsetPlugin: SuperPlugin {
    static let shared = ThemeSunsetPlugin()
    static var shouldRegister: Bool { true }
    static var order: Int { 140 }

    private nonisolated var theme: SunsetTheme { SunsetTheme() }

    nonisolated var title: String { theme.displayName }
    nonisolated var description: String { theme.description }
    nonisolated var iconName: String { theme.iconName }

    @MainActor
    func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: SunsetTheme())]
    }
}
