import CisumUI
import BookPlugin
import SwiftUI

public actor BookSettingsPlugin: SuperPlugin {
    public static let shared = BookSettingsPlugin()
    public static let metadata = PluginMetadata(
        id: "BookSettingsPlugin",
        displayName: BookSettingsPluginInfo.title,
        description: BookSettingsPluginInfo.description,
        iconName: BookSettingsPluginInfo.iconName,
        order: BookSettingsPluginInfo.order
    )

    @MainActor
    public func addSettingView() -> AnyView? {
        AnyView(BookSettingsPluginView())
    }
}
