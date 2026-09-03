import CisumUIComponents
import KernelCore
import ProviderDocsView
import SwiftUI

public actor OpenButtonPlugin: SuperPlugin {
    public static let shared = OpenButtonPlugin()
    public static let metadata = PluginMetadata(
        displayName: String(localized: "Open Current", bundle: .module),
        description: OpenButtonPluginInfo.description,
        iconName: OpenButtonPluginInfo.iconName,
        category: .tool,
    )


    @MainActor
    public func onRegister(kernel: CisumKernel) async throws {
        if let docs = kernel.docs {
            docs.addAbout(DocsEntry(id: self.id, name: Self.metadata.displayName) { OpenButtonPluginAboutView() })
            docs.addManual(DocsEntry(id: self.id, name: Self.metadata.displayName) { OpenButtonPluginManualView() })
        }
    }

    #if os(macOS)
        @MainActor
        public func addToolBarButtons() -> [(id: String, view: AnyView)] {
            [(id: OpenButtonPluginInfo.toolbarItemId, view: AnyView(OpenCurrentButtonView()))]
        }
    #endif
}
