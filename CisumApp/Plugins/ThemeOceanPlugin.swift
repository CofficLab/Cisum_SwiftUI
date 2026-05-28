import CisumUI
import PluginThemeOcean
import SwiftUI

actor ThemeOceanPlugin: SuperPlugin {
    static let shared = ThemeOceanPlugin()
    static var shouldRegister: Bool { true }
    static var order: Int { 190 }

    private nonisolated var theme: OceanTheme { OceanTheme() }

    nonisolated var title: String { theme.displayName }
    nonisolated var description: String { theme.description }
    nonisolated var iconName: String { theme.iconName }

    @MainActor
    func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: OceanTheme())]
    }
}
