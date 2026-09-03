import CisumUIComponents
import KernelCore
import ProviderDocsView
import PluginBook
import SwiftUI

public actor BookSettingsPlugin: SuperPlugin {
    public static let shared = BookSettingsPlugin()
    public static let metadata = PluginMetadata(
        displayName: BookSettingsPluginInfo.title,
        description: BookSettingsPluginInfo.description,
        iconName: BookSettingsPluginInfo.iconName,
        order: BookSettingsPluginInfo.order,
        category: .settings,
    )


    @MainActor
    public func onRegister(kernel: CisumKernel) async throws {
        if let docs = kernel.docs {
            docs.addAbout(DocsEntry(id: self.id, name: Self.metadata.displayName) { BookSettingsPluginAboutView() })
            docs.addManual(DocsEntry(id: self.id, name: Self.metadata.displayName) { BookSettingsPluginManualView() })
        }
    }

    @MainActor
    public func addSettingNavigationItem() -> PluginSettingNavigationItem? {
        PluginSettingNavigationItem(
            id: "book-settings",
            title: BookSettingsPluginInfo.title,
            description: Self.metadata.description,
            iconName: "book",
            order: BookSettingsPluginInfo.order,
            destination: AnyView(BookSettingsPluginView())
        )
    }
}
