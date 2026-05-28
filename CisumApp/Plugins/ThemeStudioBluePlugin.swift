import CisumUI
import PluginThemeStudioBlue
import SwiftUI

actor ThemeStudioBluePlugin: SuperPlugin {
    static let shared = ThemeStudioBluePlugin()
    static var shouldRegister: Bool { true }
    static var order: Int { 130 }

    private nonisolated var theme: StudioBlueTheme { StudioBlueTheme() }

    nonisolated var title: String { theme.displayName }
    nonisolated var description: String { theme.description }
    nonisolated var iconName: String { theme.iconName }

    @MainActor
    func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: StudioBlueTheme())]
    }
}
