import CisumUI
import SwiftUI

public actor ThemeForestPlugin: SuperPlugin {
    public static let shared = ThemeForestPlugin()
    public static let metadata = PluginMetadata(
        displayName: ForestTheme().displayName,
        description: ForestTheme().description,
        iconName: ForestTheme().iconName,
        order: 150
    )

    @MainActor
    public func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: ForestTheme())]
    }
}
