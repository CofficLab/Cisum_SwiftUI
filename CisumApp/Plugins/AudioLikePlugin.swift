import Foundation
import MagicKit
import OSLog
import PluginAudioLike
import SwiftUI

actor AudioLikePlugin: SuperPlugin, SuperLog {
    static let shared = AudioLikePlugin()
    static let emoji = AudioLikePluginInfo.emoji
    static let verbose = false
    static var shouldRegister: Bool { true }
    static var order: Int { AudioLikePluginInfo.order }

    nonisolated var title: String { AudioLikePluginInfo.title }
    nonisolated var description: String { AudioLikePluginInfo.description }
    let iconName = AudioLikePluginInfo.iconName

    @MainActor func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        configureRepository()
        return AnyView(AudioLikePluginRootView(content: content))
    }

    @MainActor
    private func configureRepository() {
        do {
            AudioLikeRepositoryConfiguration.configure(databaseURL: try Config.createDatabaseFile(name: "audio_like"))
        } catch {
            os_log(.error, "AudioLikePlugin failed to configure repository: \(error.localizedDescription)")
        }
    }
}

private struct AudioLikePluginRootView<Content>: View where Content: View {
    @EnvironmentObject private var pluginProvider: PluginProvider

    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        AudioLikeRootView(
            targetSceneName: AudioScenePlugin.sceneName,
            currentSceneName: { pluginProvider.currentSceneName }
        ) {
            content
        }
    }
}
