import CisumUI
import MagicKit
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
    public func addSettingView() -> AnyView? {
        AnyView(SystemPluginSettingView())
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
