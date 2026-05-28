import CisumUI
import PluginThemeNebula
import SwiftUI

actor ThemeNebulaPlugin: SuperPlugin {
    static let shared = ThemeNebulaPlugin()
    static var shouldRegister: Bool { true }
    static var order: Int { 180 }

    private nonisolated var theme: NebulaTheme { NebulaTheme() }

    nonisolated var title: String { theme.displayName }
    nonisolated var description: String { theme.description }
    nonisolated var iconName: String { theme.iconName }

    @MainActor
    func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: NebulaTheme())]
    }
}
