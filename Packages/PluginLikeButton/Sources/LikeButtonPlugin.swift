import CisumUIComponents
import KernelCore
import ProviderDocsView
import SwiftUI

public actor LikeButtonPlugin: SuperPlugin {
    public static let shared = LikeButtonPlugin()
    public static let metadata = PluginMetadata(
        displayName: String(localized: "Like Button", bundle: .module),
        description: LikeButtonPluginInfo.description,
        iconName: LikeButtonPluginInfo.iconName,
        policy: .disabled,
        category: .like,
    )


    @MainActor
    public func onRegister(kernel: CisumKernel) async throws {
        if let docs = kernel.docs {
            docs.addAbout(DocsEntry(id: self.id, name: Self.metadata.displayName) { LikeButtonPluginAboutView() })
            docs.addManual(DocsEntry(id: self.id, name: Self.metadata.displayName) { LikeButtonPluginManualView() })
        }
    }

    @MainActor
    public func addToolBarButtons() -> [(id: String, view: AnyView)] {
        [(id: LikeButtonPluginInfo.toolbarItemId, view: AnyView(LikeToggleButtonView()))]
    }
}
