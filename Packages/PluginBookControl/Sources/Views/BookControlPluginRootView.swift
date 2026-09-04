import CisumUIComponents
import MagicPlayMan
import ProviderScene
import SwiftUI

struct BookControlPluginRootView<Content>: View where Content: View {
    @EnvironmentObject private var man: MagicPlayMan

    private let scene: (any SceneProviding)?
    private let viewModel: BookControlViewModel
    private let content: Content

    init(scene: (any SceneProviding)?, viewModel: BookControlViewModel, @ViewBuilder content: () -> Content) {
        self.scene = scene
        self.viewModel = viewModel
        self.content = content()
    }

    var body: some View {
        BookControlRootView(
            targetScene: .audiobooks,
            scene: scene,
            viewModel: viewModel
        ) {
            content
        }
        .onAppear {
            viewModel.bind(playMan: man)
        }
    }
}
