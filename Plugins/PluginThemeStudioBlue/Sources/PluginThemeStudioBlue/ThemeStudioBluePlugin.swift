import CisumUI
import SwiftUI

public actor ThemeStudioBluePlugin: SuperPlugin {
    public static let shared = ThemeStudioBluePlugin()
    public static var shouldRegister: Bool { true }
    public static var order: Int { 130 }

    private nonisolated var theme: StudioBlueTheme { StudioBlueTheme() }

    public nonisolated var title: String { theme.displayName }
    public nonisolated var description: String { theme.description }
    public nonisolated var iconName: String { theme.iconName }

    @MainActor
    public func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: StudioBlueTheme())]
    }
}
