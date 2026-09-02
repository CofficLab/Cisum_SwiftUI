import CisumUI
import SwiftUI

public actor ThemeMidnightPlugin: SuperPlugin {
    public static let shared = ThemeMidnightPlugin()
    public static let metadata = PluginMetadata(
        displayName: MidnightTheme().displayName,
        description: MidnightTheme().description,
        iconName: MidnightTheme().iconName,
        order: 160
    )

    @MainActor
    public func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: MidnightTheme())]
    }
}
