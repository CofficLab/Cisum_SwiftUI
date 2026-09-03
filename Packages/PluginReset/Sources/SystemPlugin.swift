import CisumUIComponents
import KernelCore
import SwiftUI

public actor SystemPlugin: SuperPlugin {
    public static let shared = SystemPlugin()
    public static let metadata = PluginMetadata(
        displayName: ResetPluginInfo.title,
        description: ResetPluginInfo.description,
        iconName: ResetPluginInfo.iconName,
        order: ResetPluginInfo.order
    )

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
