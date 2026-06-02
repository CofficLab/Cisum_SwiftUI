import CisumUI
import PluginBookScene
import SwiftUI

public actor BookPlayModePlugin: SuperPlugin {
    public static let shared = BookPlayModePlugin()
    public static var shouldRegister: Bool { true }
    public static var order: Int { BookPlayModePluginInfo.order }

    public nonisolated var title: String { BookPlayModePluginInfo.title }
    public nonisolated var description: String { BookPlayModePluginInfo.description }
    public nonisolated var iconName: String { BookPlayModePluginInfo.iconName }

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
