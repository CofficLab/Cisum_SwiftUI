import CisumUI
import SwiftUI

public actor ThemeOceanPlugin: SuperPlugin {
    public static let shared = ThemeOceanPlugin()
    public static let metadata = PluginMetadata(
        displayName: OceanTheme().displayName,
        description: OceanTheme().description,
        iconName: OceanTheme().iconName,
        order: 190
    )

    @MainActor
    public func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: OceanTheme())]
    }
}
