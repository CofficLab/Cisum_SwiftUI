import CisumUIComponents
import SwiftUI

public actor AudioDownloadPlugin: SuperPlugin {
    public static let shared = AudioDownloadPlugin()
    public static let metadata = PluginMetadata(
        displayName: AudioDownloadPluginInfo.title,
        description: AudioDownloadPluginInfo.description,
        iconName: AudioDownloadPluginInfo.iconName,
        order: AudioDownloadPluginInfo.order
    )

    @MainActor
    public func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(AudioDownloadPluginRootView { content() })
    }
}
