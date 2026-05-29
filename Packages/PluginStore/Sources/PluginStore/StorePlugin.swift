import CisumUI
import SwiftUI

public actor StorePlugin: SuperPlugin {
    public static let shared = StorePlugin()
    public static var shouldRegister: Bool { true }
    public static var order: Int { 80 }

    public nonisolated var title: String { String(localized: String.LocalizationValue(StorePluginInfo.titleKey), table: StorePluginInfo.table, bundle: .module) }
    public nonisolated var description: String { String(localized: String.LocalizationValue(StorePluginInfo.descriptionKey), table: StorePluginInfo.table, bundle: .module) }
    public nonisolated var iconName: String { StorePluginInfo.iconName }

    @MainActor
    public func addSettingView() -> AnyView? {
        AnyView(StoreSetting())
    }
}
