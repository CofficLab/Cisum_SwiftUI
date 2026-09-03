import CisumUIComponents
import PluginBookScene
import ProviderScene
import SwiftUI

struct BookControlPluginRootView<Content>: View where Content: View {
    private let scene: (any SceneProviding)?
    private let content: Content

    init(scene: (any SceneProviding)?, @ViewBuilder content: () -> Content) {
        self.scene = scene
        self.content = content()
    }

    var body: some View {
        BookControlRootView(
            targetSceneName: BookScenePlugin.sceneName,
            scene: scene
        ) {
            content
        }
    }
}
