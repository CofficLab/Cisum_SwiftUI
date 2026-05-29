import CisumUI
import SwiftUI

public actor ThemePaperPlugin: SuperPlugin {
    public static let shared = ThemePaperPlugin()
    public static var shouldRegister: Bool { true }
    public static var order: Int { 200 }

    private nonisolated var theme: PaperTheme { PaperTheme() }

    public nonisolated var title: String { theme.displayName }
    public nonisolated var description: String { theme.description }
    public nonisolated var iconName: String { theme.iconName }

    @MainActor
    public func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: PaperTheme())]
    }
}
