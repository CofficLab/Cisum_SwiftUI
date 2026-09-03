import CisumUIComponents
import PluginBookScene
import ProviderScene
import SwiftUI

struct BookLikePluginRootView<Content>: View where Content: View {
    private let scene: (any SceneProviding)?
    private let content: Content

    init(scene: (any SceneProviding)?, @ViewBuilder content: () -> Content) {
        self.scene = scene
        self.content = content()
    }

    var body: some View {
        BookLikeRootView(
            targetSceneName: BookScenePlugin.sceneName,
            scene: scene
        ) {
            content
        }
    }
}
