import CisumUI
import SwiftUI

public actor OpenButtonPlugin: SuperPlugin {
    public static let shared = OpenButtonPlugin()
    public static var shouldRegister: Bool { true }

    public nonisolated var description: String { OpenButtonPluginInfo.description }
    public nonisolated var iconName: String { OpenButtonPluginInfo.iconName }

    #if os(macOS)
        @MainActor
        public func addToolBarButtons() -> [(id: String, view: AnyView)] {
            [(id: OpenButtonPluginInfo.toolbarItemId, view: AnyView(OpenCurrentButtonView()))]
        }
    #endif
}
