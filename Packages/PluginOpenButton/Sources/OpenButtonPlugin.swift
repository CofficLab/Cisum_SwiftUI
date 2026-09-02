import CisumUIComponents
import SwiftUI

public actor OpenButtonPlugin: SuperPlugin {
    public static let shared = OpenButtonPlugin()
    public static let metadata = PluginMetadata(
        displayName: String(localized: "Open Current", bundle: .module),
        description: OpenButtonPluginInfo.description,
        iconName: OpenButtonPluginInfo.iconName
    )

    #if os(macOS)
        @MainActor
        public func addToolBarButtons() -> [(id: String, view: AnyView)] {
            [(id: OpenButtonPluginInfo.toolbarItemId, view: AnyView(OpenCurrentButtonView()))]
        }
    #endif
}
