import CisumUI
import BookScenePlugin
import SwiftUI

public actor BookControlPlugin: SuperPlugin {
    public static let shared = BookControlPlugin()
    public static var shouldRegister: Bool { true }
    public static var order: Int { BookControlPluginInfo.order }

    public nonisolated var title: String { BookControlPluginInfo.title }
    public nonisolated var description: String { BookControlPluginInfo.description }
    public nonisolated var iconName: String { BookControlPluginInfo.iconName }

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
