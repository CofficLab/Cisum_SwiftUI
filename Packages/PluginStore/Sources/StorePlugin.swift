import CisumUIComponents
import SwiftUI

public actor StorePlugin: SuperPlugin {
    public static let shared = StorePlugin()
    public static let metadata = PluginMetadata(
        displayName: String(localized: String.LocalizationValue(StorePluginInfo.titleKey), bundle: .module),
        description: String(localized: String.LocalizationValue(StorePluginInfo.descriptionKey), bundle: .module),
        iconName: StorePluginInfo.iconName,
        order: 80
    )

    @MainActor
    public func addSettingNavigationItem() -> PluginSettingNavigationItem? {
        PluginSettingNavigationItem(
            id: "store",
            title: String(localized: String.LocalizationValue(StorePluginInfo.titleKey), bundle: .module),
            description: Self.metadata.description,
            iconName: StorePluginInfo.iconName,
            order: 80,
            destination: AnyView(StoreSetting())
        )
    }
}
