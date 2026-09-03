import CisumUIComponents
import KernelCore
import ProviderDocsView
import PluginAudio
import SwiftUI

public actor AudioSettingsPlugin: SuperPlugin {
    public static let shared = AudioSettingsPlugin()
    public static let metadata = PluginMetadata(
        displayName: AudioSettingsPluginInfo.title,
        description: AudioSettingsPluginInfo.description,
        iconName: AudioSettingsPluginInfo.iconName,
        order: AudioSettingsPluginInfo.order,
        category: .settings,
    )


    @MainActor
    public func onRegister(kernel: CisumKernel) async throws {
        if let docs = kernel.docs {
            docs.addAbout(DocsEntry(id: self.id, name: Self.metadata.displayName) { AudioSettingsPluginAboutView() })
            docs.addManual(DocsEntry(id: self.id, name: Self.metadata.displayName) { AudioSettingsPluginManualView() })
        }
    }

    @MainActor
    public func addSettingNavigationItem() -> PluginSettingNavigationItem? {
        PluginSettingNavigationItem(
            id: "audio-settings",
            title: AudioSettingsPluginInfo.title,
            description: Self.metadata.description,
            iconName: "slider.horizontal.3",
            order: AudioSettingsPluginInfo.order,
            destination: AnyView(AudioSettingsPluginView())
        )
    }
}
