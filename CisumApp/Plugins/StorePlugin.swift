import Foundation
import MagicKit
import OSLog
import PluginStore
import SwiftUI

actor StorePlugin: SuperPlugin {
    static let shared = StorePlugin()
    static var shouldRegister: Bool { true }
    static var order: Int { 80 }

    nonisolated var title: String { String(localized: String.LocalizationValue(StorePluginInfo.titleKey), table: StorePluginInfo.table) }
    nonisolated var description: String { String(localized: String.LocalizationValue(StorePluginInfo.descriptionKey), table: StorePluginInfo.table) }
    let iconName = StorePluginInfo.iconName

    @MainActor
    func addSettingView() -> AnyView? {
        AnyView(StoreSetting())
    }
}
