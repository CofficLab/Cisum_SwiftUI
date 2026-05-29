import CisumUI
import SwiftUI

public actor ThemeMonoPlugin: SuperPlugin {
    public static let shared = ThemeMonoPlugin()
    public static var shouldRegister: Bool { true }
    public static var order: Int { 170 }

    private nonisolated var theme: MonoTheme { MonoTheme() }

    public nonisolated var title: String { theme.displayName }
    public nonisolated var description: String { theme.description }
    public nonisolated var iconName: String { theme.iconName }

    @MainActor
    public func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: MonoTheme())]
    }
}
