import CisumUI
import BookScenePlugin
import SwiftUI

public actor BookPlayModePlugin: SuperPlugin {
    public static let shared = BookPlayModePlugin()
    public static let metadata = PluginMetadata(
        id: "BookPlayModePlugin",
        displayName: BookPlayModePluginInfo.title,
        description: BookPlayModePluginInfo.description,
        iconName: BookPlayModePluginInfo.iconName,
        order: BookPlayModePluginInfo.order
    )

    @MainActor
    public func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(BookPlayModePluginRootView(content: content))
    }
}

private struct BookPlayModePluginRootView<Content>: View where Content: View {
    @Environment(\.currentSceneName) private var currentSceneName
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        BookPlayModeRootView(
            targetSceneName: BookScenePlugin.sceneName,
            currentSceneName: { currentSceneName }
        ) {
            content
        }
    }
}
