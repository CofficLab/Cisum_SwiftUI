import CisumUI
import SwiftUI

public actor ThemeMonoPlugin: SuperPlugin {
    public static let shared = ThemeMonoPlugin()
    public static let metadata = PluginMetadata(
        id: "ThemeMonoPlugin",
        displayName: MonoTheme().displayName,
        description: MonoTheme().description,
        iconName: MonoTheme().iconName,
        order: 170
    )

    @MainActor
    public func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: MonoTheme())]
    }
}
