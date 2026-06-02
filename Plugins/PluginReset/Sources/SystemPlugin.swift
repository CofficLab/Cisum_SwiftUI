import CisumUI
import MagicKit
import SwiftUI

public actor SystemPlugin: SuperPlugin {
    public static let shared = SystemPlugin()
    public static var shouldRegister: Bool { true }
    public static var order: Int { ResetPluginInfo.order }

    public nonisolated var title: String { ResetPluginInfo.title }
    public nonisolated var description: String { ResetPluginInfo.description }
    public nonisolated var iconName: String { ResetPluginInfo.iconName }

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
