import KernelCore
import CisumUIComponents
import ProviderScene
import SwiftUI

public actor AudioScenePlugin: SuperPlugin {
    public static let shared = AudioScenePlugin()
    public static let metadata = PluginMetadata(
        displayName: AudioScenePluginInfo.title,
        description: AudioScenePluginInfo.description,
        iconName: AudioScenePluginInfo.iconName,
        order: AudioScenePluginInfo.order
    )

    nonisolated(unsafe) private var setSceneAction: (@MainActor (AppScene) -> Void)?

    @MainActor
    public func onBoot(kernel: CisumKernel) async throws {
        guard let scene = kernel.resolveProvider((any SceneProviding).self) else {
            throw CisumKernelError.serviceNotAvailable(service: "SceneProviding")
        }
        self.setSceneAction = { @MainActor sceneValue in
            scene.setCurrentScene(sceneValue)
        }
    }

    @MainActor
    public func onShutdown(kernel: CisumKernel) async throws {
        setSceneAction = nil
    }

    @MainActor
    public func addPosterView() -> AnyView? {
        AnyView(AudioScenePluginPosterView(setCurrentScene: setSceneAction ?? { _ in }))
    }
}
