import CisumUIComponents
import PluginBookScene
import SwiftUI

public actor BookPlayModePlugin: SuperPlugin {
    public static let shared = BookPlayModePlugin()
    public static let metadata = PluginMetadata(
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
