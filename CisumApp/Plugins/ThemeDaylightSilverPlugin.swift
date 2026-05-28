import CisumUI
import PluginThemeDaylightSilver
import SwiftUI

actor ThemeDaylightSilverPlugin: SuperPlugin {
    static let shared = ThemeDaylightSilverPlugin()
    static var shouldRegister: Bool { true }
    static var order: Int { 110 }

    private nonisolated var theme: DaylightSilverTheme { DaylightSilverTheme() }

    nonisolated var title: String { theme.displayName }
    nonisolated var description: String { theme.description }
    nonisolated var iconName: String { theme.iconName }

    @MainActor
    func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: DaylightSilverTheme())]
    }
}
