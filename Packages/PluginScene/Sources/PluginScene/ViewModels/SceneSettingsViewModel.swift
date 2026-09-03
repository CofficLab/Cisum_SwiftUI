import Combine
import Foundation
import ProviderScene

@MainActor
final class SceneSettingsViewModel: ObservableObject {
    @Published private(set) var sceneNames: [String] = []
    @Published private(set) var currentSceneName: String?
    @Published private(set) var errorMessage: String?

    private weak var scene: (any SceneProviding)?
    private var observer: SceneProvidingObserver?

    init(scene: (any SceneProviding)?) {
        attach(to: scene)
    }

    var currentSceneIconName: String {
        guard let currentSceneName else { return "rectangle.3.group" }
        return iconName(for: currentSceneName)
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

    func select(_ sceneName: String) {
        guard let scene else { return }
        errorMessage = nil
        do {
            try scene.setCurrentScene(sceneName)
            refresh()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func iconName(for sceneName: String) -> String {
        scene?.plugin(for: sceneName)?.iconName ?? "rectangle.3.group"
    }

    func handle(_ event: ScenePluginEvent) {
        switch event {
        case .providerChanged:
            refresh()
        }
    }

    private func refresh() {
        sceneNames = scene?.sceneNames ?? []
        currentSceneName = scene?.currentSceneName
    }
}
