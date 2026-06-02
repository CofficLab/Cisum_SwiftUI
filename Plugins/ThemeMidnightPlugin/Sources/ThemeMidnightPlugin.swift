import CisumUI
import SwiftUI

public actor ThemeMidnightPlugin: SuperPlugin {
    public static let shared = ThemeMidnightPlugin()
    public static var shouldRegister: Bool { true }
    public static var order: Int { 160 }

    private nonisolated var theme: MidnightTheme { MidnightTheme() }

    public nonisolated var title: String { theme.displayName }
    public nonisolated var description: String { theme.description }
    public nonisolated var iconName: String { theme.iconName }

    @MainActor
    public func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: MidnightTheme())]
    }
}
