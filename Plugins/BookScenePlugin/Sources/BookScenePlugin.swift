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

private struct BookScenePluginPosterView: View {
    @Environment(\.posterDismissAction) private var dismissAction
    @Environment(\.setCurrentSceneAction) private var setCurrentScene

    var body: some View {
        BookPosterView(
            enterScene: {
                try setCurrentScene(BookScenePlugin.sceneName)
            },
            dismissPoster: {
                dismissAction()
            }
        )
    }
}
