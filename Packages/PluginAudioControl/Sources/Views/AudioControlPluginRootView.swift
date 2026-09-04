import CisumUIComponents
import PluginAudio
import ProviderScene
import SwiftUI

struct AudioControlPluginRootView<Content>: View where Content: View {
    @EnvironmentObject private var man: MagicPlayMan

    private let scene: (any SceneProviding)?
    private let viewModel: AudioControlViewModel
    private let content: Content

    init(scene: (any SceneProviding)?, viewModel: AudioControlViewModel, @ViewBuilder content: () -> Content) {
        self.scene = scene
        self.viewModel = viewModel
        self.content = content()
    }

    var body: some View {
        AudioControlRootView(
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
