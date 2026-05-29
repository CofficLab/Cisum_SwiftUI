import CisumUI
import SwiftUI

public actor ThemeNebulaPlugin: SuperPlugin {
    public static let shared = ThemeNebulaPlugin()
    public static var shouldRegister: Bool { true }
    public static var order: Int { 180 }

    private nonisolated var theme: NebulaTheme { NebulaTheme() }

    public nonisolated var title: String { theme.displayName }
    public nonisolated var description: String { theme.description }
    public nonisolated var iconName: String { theme.iconName }

    @MainActor
    public func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: NebulaTheme())]
    }
}
