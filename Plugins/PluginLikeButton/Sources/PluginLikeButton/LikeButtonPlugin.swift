import CisumUI
import SwiftUI

public actor LikeButtonPlugin: SuperPlugin {
    public static let shared = LikeButtonPlugin()
    public static var shouldRegister: Bool { false }

    public nonisolated var description: String { LikeButtonPluginInfo.description }
    public nonisolated var iconName: String { LikeButtonPluginInfo.iconName }

    @MainActor
    public func addToolBarButtons() -> [(id: String, view: AnyView)] {
        [(id: LikeButtonPluginInfo.toolbarItemId, view: AnyView(LikeToggleButtonView()))]
    }
}
