import Combine
import Foundation
import ProviderScene
import MagicKit

@MainActor
final class SceneSettingsViewModel: ObservableObject, SuperLog {
    nonisolated static let verbose = false

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
