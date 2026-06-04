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
