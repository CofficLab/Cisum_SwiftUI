import CisumUI
import SwiftUI

public actor ThemeStudioBluePlugin: SuperPlugin {
    public static let shared = ThemeStudioBluePlugin()
    public static let metadata = PluginMetadata(
        id: "ThemeStudioBluePlugin",
        displayName: StudioBlueTheme().displayName,
        description: StudioBlueTheme().description,
        iconName: StudioBlueTheme().iconName,
        order: 130
    )

    @MainActor
    public func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: StudioBlueTheme())]
    }
}
