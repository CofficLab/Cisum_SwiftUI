import CisumKernel
import CisumUIComponents
import ProviderScene
import SwiftUI

public actor AudioScenePlugin: SuperPlugin, CisumKernelPlugin {
    public static let shared = AudioScenePlugin()
    public static let metadata = PluginMetadata(
        displayName: AudioScenePluginInfo.title,
        description: AudioScenePluginInfo.description,
        iconName: AudioScenePluginInfo.iconName,
        order: AudioScenePluginInfo.order
    )
    public static let sceneName = AudioScenePluginInfo.sceneName

    nonisolated(unsafe) private var setSceneAction: (@MainActor (String) throws -> Void)?

    @MainActor
    public func onBoot(kernel: CisumKernel) async throws {
        guard let scene = kernel.resolveProvider((any SceneProviding).self) else {
            throw CisumKernelError.serviceNotAvailable(service: "SceneProviding")
        }
        self.setSceneAction = { @MainActor sceneName in
            try scene.setCurrentScene(sceneName)
        }
    }

    @MainActor
    public func onShutdown(kernel: CisumKernel) async throws {
        setSceneAction = nil
    }

    @MainActor
    public func addSceneItem() -> String? {
        Self.sceneName
    }

    @MainActor
    public func addPosterView() -> AnyView? {
        AnyView(AudioScenePluginPosterView(setCurrentScene: setSceneAction ?? { _ in }))
    }


    private final class SceneBox {
        weak var scene: (any SceneProviding)?
    }
}
