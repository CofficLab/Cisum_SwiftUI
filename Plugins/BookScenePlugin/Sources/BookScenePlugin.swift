import CisumUI
import SwiftUI

public actor BookScenePlugin: SuperPlugin {
    public static let shared = BookScenePlugin()
    public static let metadata = PluginMetadata(
        id: "BookScenePlugin",
        displayName: BookScenePluginInfo.title,
        description: BookScenePluginInfo.description,
        iconName: BookScenePluginInfo.iconName,
        order: BookScenePluginInfo.order
    )
    public static let sceneName = BookScenePluginInfo.sceneName

    @MainActor
    public func addSceneItem() -> String? {
        Self.sceneName
    }

    @MainActor
    public func addPosterView() -> AnyView? {
        AnyView(BookScenePluginPosterView())
    }
}
