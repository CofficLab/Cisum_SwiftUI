import Foundation
import MagicKit
import OSLog
import PluginBookScene
import SwiftData
import SwiftUI

actor BookScenePlugin: SuperPlugin {
    static let shared = BookScenePlugin()
    static var shouldRegister: Bool { true }
    static var order: Int { BookScenePluginInfo.order }
    nonisolated var title: String { BookScenePluginInfo.title }
    nonisolated var description: String { BookScenePluginInfo.description }
    let iconName = BookScenePluginInfo.iconName
    static let sceneName = BookScenePluginInfo.sceneName

    /// Provides "Audiobooks" scene
    @MainActor func addSceneItem() -> String? {
        return Self.sceneName
    }

    /// 提供有声书封面视图
    @MainActor
    func addPosterView() -> AnyView? {
        AnyView(BookScenePluginPosterView())
    }
}

private struct BookScenePluginPosterView: View {
    @Environment(\.posterDismissAction) private var dismissAction
    @EnvironmentObject private var pluginProvider: PluginProvider

    var body: some View {
        BookPosterView(
            enterScene: {
                try pluginProvider.setCurrentScene(BookScenePlugin.sceneName)
            },
            dismissPoster: {
                dismissAction()
            }
        )
    }
}
