import CisumUI
import SwiftUI

public actor ThemeSunsetPlugin: SuperPlugin {
    public static let shared = ThemeSunsetPlugin()
    public static var shouldRegister: Bool { true }
    public static var order: Int { 140 }

    private nonisolated var theme: SunsetTheme { SunsetTheme() }

    public nonisolated var title: String { theme.displayName }
    public nonisolated var description: String { theme.description }
    public nonisolated var iconName: String { theme.iconName }

    @MainActor
    public func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: SunsetTheme())]
    }
}
