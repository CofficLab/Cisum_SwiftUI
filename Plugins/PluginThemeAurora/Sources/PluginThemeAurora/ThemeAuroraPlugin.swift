import CisumUI
import SwiftUI

public actor ThemeAuroraPlugin: SuperPlugin {
    public static let shared = ThemeAuroraPlugin()
    public static var shouldRegister: Bool { true }
    public static var order: Int { 120 }

    private nonisolated var theme: AuroraTheme { AuroraTheme() }

    public nonisolated var title: String { theme.displayName }
    public nonisolated var description: String { theme.description }
    public nonisolated var iconName: String { theme.iconName }

    @MainActor
    public func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: AuroraTheme())]
    }
}
