import CisumUI
import PluginThemeMono
import SwiftUI

actor ThemeMonoPlugin: SuperPlugin {
    static let shared = ThemeMonoPlugin()
    static var shouldRegister: Bool { true }
    static var order: Int { 170 }

    private nonisolated var theme: MonoTheme { MonoTheme() }

    nonisolated var title: String { theme.displayName }
    nonisolated var description: String { theme.description }
    nonisolated var iconName: String { theme.iconName }

    @MainActor
    func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: MonoTheme())]
    }
}
