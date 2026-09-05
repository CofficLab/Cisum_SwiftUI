import Combine
import Foundation
import ProviderScene

@MainActor
final class SceneSettingsViewModel: ObservableObject {
    @Published private(set) var scenes: [AppScene] = []
    @Published private(set) var currentScene: AppScene?

    private let capability: (any SceneSettingsCapability)?

    init(capability: (any SceneSettingsCapability)?) {
        self.capability = capability
        refresh()
    }

    var currentSceneIconName: String {
        currentScene?.iconName ?? "rectangle.3.group"
    }

    func select(_ target: AppScene) {
        capability?.setCurrentScene(target)
        refresh()
    }

    func handleProviderChanged() {
        refresh()
    }

    private func refresh() {
        scenes = capability?.scenes ?? []
        currentScene = capability?.currentScene
    }
}
