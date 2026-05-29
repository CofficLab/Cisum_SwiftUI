import CisumUI
import SwiftUI

public actor ThemeGraphiteBlackPlugin: SuperPlugin {
    public static let shared = ThemeGraphiteBlackPlugin()
    public static var shouldRegister: Bool { true }
    public static var order: Int { 155 }

    private nonisolated var theme: GraphiteBlackTheme { GraphiteBlackTheme() }

    public nonisolated var title: String { theme.displayName }
    public nonisolated var description: String { theme.description }
    public nonisolated var iconName: String { theme.iconName }

    @MainActor
    public func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: GraphiteBlackTheme())]
    }
}
