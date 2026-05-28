import Foundation
import MagicKit
import OSLog
import PluginAudioScene
import SwiftData
import SwiftUI

actor AudioScenePlugin: SuperPlugin {
    static let shared = AudioScenePlugin()
    static var shouldRegister: Bool { true }
    static var order: Int { AudioScenePluginInfo.order }

    nonisolated var title: String { AudioScenePluginInfo.title }
    nonisolated var description: String { AudioScenePluginInfo.description }
    let iconName = AudioScenePluginInfo.iconName
    static let sceneName = AudioScenePluginInfo.sceneName

    /// Provides "Music Library" scene
    @MainActor func addSceneItem() -> String? {
        return Self.sceneName
    }

    /// 提供音频海报视图
    @MainActor
    func addPosterView() -> AnyView? {
        AnyView(AudioScenePluginPosterView())
    }
}

private struct AudioScenePluginPosterView: View {
    @Environment(\.posterDismissAction) private var dismissAction
    @EnvironmentObject private var pluginProvider: PluginProvider

    var body: some View {
        AudioPosterView(
            enterScene: {
                try pluginProvider.setCurrentScene(AudioScenePlugin.sceneName)
            },
            dismissPoster: {
                dismissAction()
            }
        )
    }
}
