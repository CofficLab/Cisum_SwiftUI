import CisumUI
import SwiftUI

public actor LikeButtonPlugin: SuperPlugin {
    public static let shared = LikeButtonPlugin()
    public static let metadata = PluginMetadata(
        displayName: String(localized: "Like Button", bundle: .module),
        description: LikeButtonPluginInfo.description,
        iconName: LikeButtonPluginInfo.iconName,
        policy: .disabled
    )

    @MainActor
    public func addToolBarButtons() -> [(id: String, view: AnyView)] {
        [(id: LikeButtonPluginInfo.toolbarItemId, view: AnyView(LikeToggleButtonView()))]
    }
}
