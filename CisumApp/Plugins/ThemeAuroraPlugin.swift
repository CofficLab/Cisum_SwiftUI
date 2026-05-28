import CisumUI
import PluginThemeAurora
import SwiftUI

actor ThemeAuroraPlugin: SuperPlugin {
    static let shared = ThemeAuroraPlugin()
    static var shouldRegister: Bool { true }
    static var order: Int { 120 }

    private nonisolated var theme: AuroraTheme { AuroraTheme() }

    nonisolated var title: String { theme.displayName }
    nonisolated var description: String { theme.description }
    nonisolated var iconName: String { theme.iconName }

    @MainActor
    func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: AuroraTheme())]
    }
}
