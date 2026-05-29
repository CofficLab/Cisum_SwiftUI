import CisumUI
import SwiftUI

public actor BookScenePlugin: SuperPlugin {
    public static let shared = BookScenePlugin()
    public static var shouldRegister: Bool { true }
    public static var order: Int { BookScenePluginInfo.order }

    public nonisolated var title: String { BookScenePluginInfo.title }
    public nonisolated var description: String { BookScenePluginInfo.description }
    public nonisolated var iconName: String { BookScenePluginInfo.iconName }
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
