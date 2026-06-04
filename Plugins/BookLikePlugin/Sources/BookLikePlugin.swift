import CisumUI
import BookScenePlugin
import SwiftUI

public actor BookLikePlugin: SuperPlugin {
    public static let shared = BookLikePlugin()
    public static let metadata = PluginMetadata(
        id: "BookLikePlugin",
        displayName: BookLikePluginInfo.title,
        description: BookLikePluginInfo.description,
        iconName: BookLikePluginInfo.iconName,
        order: BookLikePluginInfo.order
    )

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
            description: Self.metadata.description,
            iconName: Self.metadata.iconName,
            order: Self.metadata.order,
            destination: AnyView(BookLikeSettingsView())
        )
    }
}
