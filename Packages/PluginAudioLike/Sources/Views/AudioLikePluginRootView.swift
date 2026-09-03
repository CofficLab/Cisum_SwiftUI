import CisumUIComponents
import MagicPlayMan
import ProviderScene
import SwiftUI

struct AudioLikePluginRootView<Content>: View where Content: View {
    @EnvironmentObject private var man: MagicPlayMan

    private let scene: (any SceneProviding)?
    private let viewModel: AudioLikeViewModel
    private let content: Content

    init(
        scene: (any SceneProviding)?,
        viewModel: AudioLikeViewModel,
        @ViewBuilder content: () -> Content
    ) {
        self.scene = scene
        self.viewModel = viewModel
        self.content = content()
    }

    var body: some View {
        AudioLikeRootView(
            targetScene: .music,
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
