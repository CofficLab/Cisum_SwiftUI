import CisumUI
import SwiftUI

public actor AudioDownloadPlugin: SuperPlugin {
    public static let shared = AudioDownloadPlugin()
    public static let metadata = PluginMetadata(
        id: "AudioDownloadPlugin",
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

private struct AudioDownloadPluginRootView<Content>: View where Content: View {
    @Environment(\.currentSceneName) private var currentSceneName
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        AudioDownloadRootView(currentSceneName: { currentSceneName }) {
            content
        }
    }
}
