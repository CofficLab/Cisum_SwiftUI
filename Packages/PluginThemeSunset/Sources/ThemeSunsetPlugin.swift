import CisumUIComponents
import KernelCore
import ProviderDocsView
import SwiftUI

public actor ThemeSunsetPlugin: SuperPlugin {
    public static let shared = ThemeSunsetPlugin()
    public static let metadata = PluginMetadata(
        displayName: SunsetTheme().displayName,
        description: SunsetTheme().description,
        iconName: SunsetTheme().iconName,
        order: 140,
        category: .theme,
    )


    @MainActor
    public func onRegister(kernel: CisumKernel) async throws {
        if let docs = kernel.docs {
            docs.addAbout(DocsEntry(id: self.id, name: Self.metadata.displayName) { ThemeSunsetPluginAboutView() })
            docs.addManual(DocsEntry(id: self.id, name: Self.metadata.displayName) { ThemeSunsetPluginManualView() })
        }
    }

    @MainActor
    public func addThemeContributions() -> [LumiUIThemeContribution] {
        [LumiUIThemeContribution(
        sortKey: ThemeSortKey(pluginOrder: 140, themeId: SunsetTheme().identifier),
        chromeTheme: SunsetTheme(),
        editorThemeId: SunsetTheme().identifier
    )]
    }
}
