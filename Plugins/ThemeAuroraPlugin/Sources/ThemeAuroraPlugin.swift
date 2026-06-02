import CisumUI
import SwiftUI

public actor ThemeAuroraPlugin: SuperPlugin {
    public static let shared = ThemeAuroraPlugin()
    public static let metadata = PluginMetadata(
        id: "ThemeAuroraPlugin",
        displayName: AuroraTheme().displayName,
        description: AuroraTheme().description,
        iconName: AuroraTheme().iconName,
        order: 120
    )

    @MainActor
    public func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: AuroraTheme())]
    }
}
