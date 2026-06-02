import CisumUI
import BookScenePlugin
import SwiftUI

public actor BookControlPlugin: SuperPlugin {
    public static let shared = BookControlPlugin()
    public static let metadata = PluginMetadata(
        id: "BookControlPlugin",
        displayName: BookControlPluginInfo.title,
        description: BookControlPluginInfo.description,
        iconName: BookControlPluginInfo.iconName,
        order: BookControlPluginInfo.order
    )

    @MainActor
    public func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(BookControlPluginRootView(content: content))
    }
}

private struct BookControlPluginRootView<Content>: View where Content: View {
    @Environment(\.currentSceneName) private var currentSceneName
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        BookControlRootView(
            targetSceneName: BookScenePlugin.sceneName,
            currentSceneName: { currentSceneName }
        ) {
            content
        }
    }
}
