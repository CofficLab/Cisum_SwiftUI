import CisumUI
import SwiftUI

public actor ThemeDaylightSilverPlugin: SuperPlugin {
    public static let shared = ThemeDaylightSilverPlugin()
    public static var shouldRegister: Bool { true }
    public static var order: Int { 110 }

    private nonisolated var theme: DaylightSilverTheme { DaylightSilverTheme() }

    public nonisolated var title: String { theme.displayName }
    public nonisolated var description: String { theme.description }
    public nonisolated var iconName: String { theme.iconName }

    @MainActor
    public func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: DaylightSilverTheme())]
    }
}
