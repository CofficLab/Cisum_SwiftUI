import CisumUIComponents
import KernelCore
import ProviderDocsView
import SwiftUI

public actor ThemeOceanPlugin: SuperPlugin {
    public static let shared = ThemeOceanPlugin()
    public static let metadata = PluginMetadata(
        displayName: OceanTheme().displayName,
        description: OceanTheme().description,
        iconName: OceanTheme().iconName,
        order: 190,
        category: .theme,
    )


    @MainActor
    public func onRegister(kernel: CisumKernel) async throws {
        if let docs = kernel.docs {
            docs.addAbout(DocsEntry(id: self.id, name: Self.metadata.displayName) { ThemeOceanPluginAboutView() })
            docs.addManual(DocsEntry(id: self.id, name: Self.metadata.displayName) { ThemeOceanPluginManualView() })
        }
    }

    @MainActor
    public func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(
        sortKey: ThemeSortKey(pluginOrder: 190, themeId: OceanTheme().identifier),
        chromeTheme: OceanTheme(),
        editorThemeId: OceanTheme().identifier
    )]
    }
}
