import CisumUI
import PluginThemeCisum
import SwiftUI

actor ThemeCisumPlugin: SuperPlugin {
    static let shared = ThemeCisumPlugin()
    static var shouldRegister: Bool { true }
    static var order: Int { 100 }

    private nonisolated var theme: CisumTheme { CisumTheme() }

    nonisolated var title: String { theme.displayName }
    nonisolated var description: String { theme.description }
    nonisolated var iconName: String { theme.iconName }

    @MainActor
    func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: CisumTheme())]
    }
}
