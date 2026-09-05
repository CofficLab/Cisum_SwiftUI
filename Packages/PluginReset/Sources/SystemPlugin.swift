import CisumUIComponents
import KernelCore
import ProviderDocsView
import SwiftUI
import MagicKit

public actor SystemPlugin: SuperPlugin, SuperLog {
    nonisolated static let verbose = false

    public static let shared = SystemPlugin()
    public static let metadata = PluginMetadata(
        displayName: ResetPluginInfo.title,
        description: ResetPluginInfo.description,
        iconName: ResetPluginInfo.iconName,
        order: ResetPluginInfo.order,
        category: .system,
    )


    @MainActor
    public func onRegister(kernel: CisumKernel) async throws {
        if let docs = kernel.docs {
            docs.addAbout(DocsEntry(id: self.id, name: Self.metadata.displayName) { SystemPluginAboutView() })
            docs.addManual(DocsEntry(id: self.id, name: Self.metadata.displayName) { SystemPluginManualView() })
        }
    }

    @MainActor
    public func addSettingNavigationItem() -> PluginSettingNavigationItem? {
        PluginSettingNavigationItem(
            id: "system",
            title: ResetPluginInfo.title,
            description: Self.metadata.description,
            iconName: "gearshape.2",
            order: ResetPluginInfo.order,
            destination: AnyView(SystemPluginSettingView())
        )
    }
}

private struct SystemPluginSettingView: View {
    @Environment(\.resetSettingsAction) private var resetSettings

    var body: some View {
        SystemSetting(
            appVersion: MagicApp.getVersion(),
            resetSettings: resetSettings
        )
    }
}
