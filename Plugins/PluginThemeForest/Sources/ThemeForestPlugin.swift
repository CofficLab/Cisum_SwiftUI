import CisumUI
import SwiftUI

public actor ThemeForestPlugin: SuperPlugin {
    public static let shared = ThemeForestPlugin()
    public static var shouldRegister: Bool { true }
    public static var order: Int { 150 }

    private nonisolated var theme: ForestTheme { ForestTheme() }

    public nonisolated var title: String { theme.displayName }
    public nonisolated var description: String { theme.description }
    public nonisolated var iconName: String { theme.iconName }

    @MainActor
    public func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: ForestTheme())]
    }
}
