import CisumUIComponents
import MagicPlayMan
import OSLog
import PluginBook
import ProviderScene
import SwiftData
import SwiftUI

struct BookProgressPluginRootView<Content>: View where Content: View {
    @EnvironmentObject private var man: MagicPlayMan

    private let scene: (any SceneProviding)?
    private let viewModel: BookProgressViewModel
    private let content: Content

    init(scene: (any SceneProviding)?, viewModel: BookProgressViewModel, @ViewBuilder content: () -> Content) {
        self.scene = scene
        self.viewModel = viewModel
        self.content = content()
    }

    var body: some View {
        BookProgressRootView(
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
