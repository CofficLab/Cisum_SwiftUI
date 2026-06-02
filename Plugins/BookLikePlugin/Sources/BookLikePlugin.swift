import CisumUI
import BookScenePlugin
import SwiftUI

public actor BookLikePlugin: SuperPlugin {
    public static let shared = BookLikePlugin()
    public static var shouldRegister: Bool { true }
    public static var order: Int { BookLikePluginInfo.order }

    public nonisolated var title: String { BookLikePluginInfo.title }
    public nonisolated var description: String { BookLikePluginInfo.description }
    public nonisolated var iconName: String { BookLikePluginInfo.iconName }

    @MainActor
    public func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(BookLikePluginRootView(content: content))
    }

    @MainActor
    public func addSettingView() -> AnyView? {
        nil
    }

    @MainActor
    public func addSettingNavigationItem() -> PluginSettingNavigationItem? {
        PluginSettingNavigationItem(
            id: "liked-books",
            title: String(localized: "Liked Books", bundle: .module),
            description: BookLikePluginInfo.description,
            iconName: BookLikePluginInfo.iconName,
            order: BookLikePluginInfo.order,
            destination: AnyView(BookLikeSettingsView())
        )
    }
}

private struct BookLikePluginRootView<Content>: View where Content: View {
    @Environment(\.currentSceneName) private var currentSceneName
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        BookLikeRootView(
            targetSceneName: BookScenePlugin.sceneName,
            currentSceneName: { currentSceneName }
        ) {
            content
        }
    }
}
