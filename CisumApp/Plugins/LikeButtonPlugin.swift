import PluginLikeButton
import SwiftUI

actor LikeButtonPlugin: SuperPlugin, SuperLog {
    static let shared = LikeButtonPlugin()
    let description: String = PluginLikeButton.LikeButtonPluginInfo.description
    let iconName: String = PluginLikeButton.LikeButtonPluginInfo.iconName
    static var shouldRegister: Bool { false }
    static var verbose: Bool { false }
    nonisolated static let emoji = "🦁"

    @MainActor
    func addToolBarButtons() -> [(id: String, view: AnyView)] {
        return [(id: PluginLikeButton.LikeButtonPluginInfo.toolbarItemId, view: AnyView(LikeToggleButtonView()))]
    }
}
