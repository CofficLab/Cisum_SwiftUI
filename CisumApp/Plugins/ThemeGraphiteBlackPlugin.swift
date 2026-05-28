import CisumUI
import PluginThemeGraphiteBlack
import SwiftUI

actor ThemeGraphiteBlackPlugin: SuperPlugin {
    static let shared = ThemeGraphiteBlackPlugin()
    static var shouldRegister: Bool { true }
    static var order: Int { 155 }

    private nonisolated var theme: GraphiteBlackTheme { GraphiteBlackTheme() }

    nonisolated var title: String { theme.displayName }
    nonisolated var description: String { theme.description }
    nonisolated var iconName: String { theme.iconName }

    @MainActor
    func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: GraphiteBlackTheme())]
    }
}
