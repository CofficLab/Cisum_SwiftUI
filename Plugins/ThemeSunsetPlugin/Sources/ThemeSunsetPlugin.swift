import CisumUI
import SwiftUI

public actor ThemeSunsetPlugin: SuperPlugin {
    public static let shared = ThemeSunsetPlugin()
    public static let metadata = PluginMetadata(
        id: "ThemeSunsetPlugin",
        displayName: SunsetTheme().displayName,
        description: SunsetTheme().description,
        iconName: SunsetTheme().iconName,
        order: 140
    )

    @MainActor
    public func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: SunsetTheme())]
    }
}
