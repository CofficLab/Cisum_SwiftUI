import Combine
import Foundation
import ProviderScene

@MainActor
final class SceneSettingsViewModel: ObservableObject {
    @Published private(set) var scenes: [AppScene] = []
    @Published private(set) var currentScene: AppScene?

    private weak var scene: (any SceneProviding)?

    init(scene: (any SceneProviding)?) {
        self.scene = scene
        refresh()
    }

    var currentSceneIconName: String {
        currentScene?.iconName ?? "rectangle.3.group"
    }

    func select(_ target: AppScene) {
        guard let scene else { return }
        scene.setCurrentScene(target)
        refresh()
    }

    func handle(_ event: ScenePluginEvent) {
        switch event {
        case .providerChanged:
            refresh()
        }
    }

    private func refresh() {
        scenes = scene?.scenes ?? []
        currentScene = scene?.currentScene
    }
}
