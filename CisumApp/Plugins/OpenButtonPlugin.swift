import PluginOpenButton
import SwiftUI

actor OpenButtonPlugin: SuperPlugin, SuperLog {
    static let shared = OpenButtonPlugin()
    let description: String = PluginOpenButton.OpenButtonPluginInfo.description
    let iconName: String = PluginOpenButton.OpenButtonPluginInfo.iconName
    static var shouldRegister: Bool { true }
    static var verbose: Bool { true }
    nonisolated static let emoji = "😜"

    #if os(macOS)
        @MainActor
        func addToolBarButtons() -> [(id: String, view: AnyView)] {
            return [(id: PluginOpenButton.OpenButtonPluginInfo.toolbarItemId, view: AnyView(OpenCurrentButtonView()))]
        }
    #endif
}
