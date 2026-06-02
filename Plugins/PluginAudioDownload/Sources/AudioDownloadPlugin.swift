import CisumUI
import SwiftUI

public actor AudioDownloadPlugin: SuperPlugin {
    public static let shared = AudioDownloadPlugin()
    public static var shouldRegister: Bool { true }
    public static var order: Int { AudioDownloadPluginInfo.order }

    public nonisolated var title: String { AudioDownloadPluginInfo.title }
    public nonisolated var description: String { AudioDownloadPluginInfo.description }
    public nonisolated var iconName: String { AudioDownloadPluginInfo.iconName }

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
