import Foundation
import CisumUIComponents
import MagicPlayMan
import ProviderScene
import SwiftUI

public struct AudioLikeRootView<Content>: View, SuperLog where Content: View {
    public nonisolated static var emoji: String { AudioLikePluginInfo.emoji }

    @EnvironmentObject private var man: MagicPlayMan
    @ObservedObject private var viewModel: AudioLikeViewModel

    private let content: Content
    private let targetScene: AppScene
    private let scene: (any SceneProviding)?

    init(
        targetScene: AppScene,
        scene: (any SceneProviding)?,
        viewModel: AudioLikeViewModel,
        @ViewBuilder content: () -> Content
    ) {
        self.targetScene = targetScene
        self.scene = scene
        self.viewModel = viewModel
        self.content = content()
    }

    public var body: some View {
        content
            .onAppear {
                viewModel.bind(playMan: man)
                viewModel.handleSceneChange(scene?.currentScene, targetScene: targetScene)
            }
            .onDisappear {
                viewModel.handleSceneChange(nil, targetScene: targetScene)
            }
            .onChange(of: scene?.currentScene) { _, newScene in
                viewModel.handleSceneChange(newScene, targetScene: targetScene)
            }
    }
}
