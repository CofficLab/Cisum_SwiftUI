import CisumUIComponents
import KernelCore
import PluginBook
import SwiftUI

public actor BookSettingsPlugin: SuperPlugin {
    public static let shared = BookSettingsPlugin()
    public static let metadata = PluginMetadata(
        displayName: BookSettingsPluginInfo.title,
        description: BookSettingsPluginInfo.description,
        iconName: BookSettingsPluginInfo.iconName,
        order: BookSettingsPluginInfo.order
    )

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
