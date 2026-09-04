import CisumUIComponents
import MagicPlayMan
import PluginAudio
import ProviderScene
import SwiftUI

struct AudioProgressPluginRootView<Content>: View where Content: View {
    @EnvironmentObject private var man: MagicPlayMan

    private let scene: (any SceneProviding)?
    private let viewModel: AudioProgressViewModel
    private let content: Content

    init(scene: (any SceneProviding)?, viewModel: AudioProgressViewModel, @ViewBuilder content: () -> Content) {
        self.scene = scene
        self.viewModel = viewModel
        self.content = content()
    }

    var body: some View {
        AudioProgressRootView(
            scene: scene,
            audioScene: .music,
            viewModel: viewModel
        ) {
            content
        }
        .onAppear {
            viewModel.bind(playMan: man)
        }
    }
}
