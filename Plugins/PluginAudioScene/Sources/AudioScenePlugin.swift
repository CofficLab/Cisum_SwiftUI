import CisumUI
import SwiftUI

public actor AudioScenePlugin: SuperPlugin {
    public static let shared = AudioScenePlugin()
    public static var shouldRegister: Bool { true }
    public static var order: Int { AudioScenePluginInfo.order }

    public nonisolated var title: String { AudioScenePluginInfo.title }
    public nonisolated var description: String { AudioScenePluginInfo.description }
    public nonisolated var iconName: String { AudioScenePluginInfo.iconName }
    public static let sceneName = AudioScenePluginInfo.sceneName

    @MainActor
    public func addSceneItem() -> String? {
        Self.sceneName
    }

    @MainActor
    public func addPosterView() -> AnyView? {
        AnyView(AudioScenePluginPosterView())
    }
}

private struct AudioScenePluginPosterView: View {
    @Environment(\.posterDismissAction) private var dismissAction
    @Environment(\.setCurrentSceneAction) private var setCurrentScene

    var body: some View {
        AudioPosterView(
            enterScene: {
                try setCurrentScene(AudioScenePlugin.sceneName)
            },
            dismissPoster: {
                dismissAction()
            }
        )
    }
}
