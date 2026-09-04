import CisumUIComponents
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
            targetScene: .audiobooks,
            scene: scene
        ) {
            content
        }
    }
}
