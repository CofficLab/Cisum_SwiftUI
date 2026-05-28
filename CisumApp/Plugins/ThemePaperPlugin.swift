import CisumUI
import PluginThemePaper
import SwiftUI

actor ThemePaperPlugin: SuperPlugin {
    static let shared = ThemePaperPlugin()
    static var shouldRegister: Bool { true }
    static var order: Int { 200 }

    private nonisolated var theme: PaperTheme { PaperTheme() }

    nonisolated var title: String { theme.displayName }
    nonisolated var description: String { theme.description }
    nonisolated var iconName: String { theme.iconName }

    @MainActor
    func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: PaperTheme())]
    }
}
