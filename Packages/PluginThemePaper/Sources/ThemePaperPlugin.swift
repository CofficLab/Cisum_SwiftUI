import CisumUI
import SwiftUI

public actor ThemePaperPlugin: SuperPlugin {
    public static let shared = ThemePaperPlugin()
    public static let metadata = PluginMetadata(
        displayName: PaperTheme().displayName,
        description: PaperTheme().description,
        iconName: PaperTheme().iconName,
        order: 200
    )

    @MainActor
    public func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(appTheme: PaperTheme())]
    }
}
