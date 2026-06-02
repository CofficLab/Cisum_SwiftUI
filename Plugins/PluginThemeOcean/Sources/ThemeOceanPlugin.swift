import CisumUI
import SwiftUI

public actor ThemeOceanPlugin: SuperPlugin {
    public static let shared = ThemeOceanPlugin()
    public static var shouldRegister: Bool { true }
    public static var order: Int { 190 }

    private nonisolated var theme: OceanTheme { OceanTheme() }

    public nonisolated var title: String { theme.displayName }
    public nonisolated var description: String { theme.description }
    public nonisolated var iconName: String { theme.iconName }

    @MainActor
    public func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: OceanTheme())]
    }
}
