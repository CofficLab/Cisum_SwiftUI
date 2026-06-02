import CisumUI
import SwiftUI

public actor ThemeCisumPlugin: SuperPlugin {
    public static let shared = ThemeCisumPlugin()
    public static var shouldRegister: Bool { true }
    public static var order: Int { 100 }

    private nonisolated var theme: CisumTheme { CisumTheme() }

    public nonisolated var title: String { theme.displayName }
    public nonisolated var description: String { theme.description }
    public nonisolated var iconName: String { theme.iconName }

    @MainActor
    public func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: CisumTheme())]
    }
}
