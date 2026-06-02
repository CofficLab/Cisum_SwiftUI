import CisumUI
import PluginAudioScene
import SwiftUI

public actor AudioLikePlugin: SuperPlugin {
    public static let shared = AudioLikePlugin()
    public static var shouldRegister: Bool { true }
    public static var order: Int { AudioLikePluginInfo.order }

    public nonisolated var title: String { AudioLikePluginInfo.title }
    public nonisolated var description: String { AudioLikePluginInfo.description }
    public nonisolated var iconName: String { AudioLikePluginInfo.iconName }

    @MainActor
    public func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(AudioLikePluginRootView(content: content))
    }

    @MainActor
    public func addSettingView() -> AnyView? {
        AnyView(AudioLikeSettingsView())
    }
}

private struct AudioLikePluginRootView<Content>: View where Content: View {
    @Environment(\.currentSceneName) private var currentSceneName
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        AudioLikeRootView(
            targetSceneName: AudioScenePlugin.sceneName,
            currentSceneName: { currentSceneName }
        ) {
            content
        }
    }
}
