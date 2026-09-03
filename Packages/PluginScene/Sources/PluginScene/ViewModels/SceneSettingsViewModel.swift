import Combine
import Foundation
import ProviderScene

@MainActor
final class SceneSettingsViewModel: ObservableObject {
    @Published private(set) var scenes: [AppScene] = []
    @Published private(set) var currentScene: AppScene?

    private weak var scene: (any SceneProviding)?
    private var observer: SceneProvidingObserver?

    init(scene: (any SceneProviding)?) {
        attach(to: scene)
    }

    var currentSceneIconName: String {
        currentScene?.iconName ?? "rectangle.3.group"
    }

    func attach(to scene: (any SceneProviding)?) {
        observer?.cancel()
        observer = nil
        self.scene = scene
        refresh()

        guard let scene else { return }
        observer = SceneProvidingObserver(provider: scene, viewModel: self)
    }

    func detach() {
        observer?.cancel()
        observer = nil
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
