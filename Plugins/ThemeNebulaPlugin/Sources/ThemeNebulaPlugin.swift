import CisumUI
import SwiftUI

public actor ThemeNebulaPlugin: SuperPlugin {
    public static let shared = ThemeNebulaPlugin()
    public static let metadata = PluginMetadata(
        id: "ThemeNebulaPlugin",
        displayName: NebulaTheme().displayName,
        description: NebulaTheme().description,
        iconName: NebulaTheme().iconName,
        order: 180
    )

    @MainActor
    public func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: NebulaTheme())]
    }
}
