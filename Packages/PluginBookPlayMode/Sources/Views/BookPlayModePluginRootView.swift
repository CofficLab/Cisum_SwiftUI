import CisumUIComponents
import ProviderScene
import SwiftUI

struct BookPlayModePluginRootView<Content>: View where Content: View {
    private let scene: (any SceneProviding)?
    private let content: Content

    init(scene: (any SceneProviding)?, @ViewBuilder content: () -> Content) {
        self.scene = scene
        self.content = content()
    }

    var body: some View {
        BookPlayModeRootView(
            targetScene: .audiobooks,
            scene: scene
        ) {
            content
        }
    }
}
