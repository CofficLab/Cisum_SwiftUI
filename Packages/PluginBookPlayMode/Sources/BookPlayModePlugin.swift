import KernelCore
import CisumUIComponents
import PluginBookScene
import ProviderScene
import SwiftUI

public actor BookPlayModePlugin: SuperPlugin {
    public static let shared = BookPlayModePlugin()
    public static let metadata = PluginMetadata(
        displayName: BookPlayModePluginInfo.title,
        description: BookPlayModePluginInfo.description,
        iconName: BookPlayModePluginInfo.iconName,
        order: BookPlayModePluginInfo.order
    )

    nonisolated(unsafe) private let sceneBox = SceneBox()

    @MainActor
    public func onBoot(kernel: CisumKernel) async throws {
        guard let scene = kernel.resolveProvider((any SceneProviding).self) else {
            throw CisumKernelError.serviceNotAvailable(service: "SceneProviding")
        }
        sceneBox.scene = scene
    }

    @MainActor
    public func onShutdown(kernel: CisumKernel) async throws {
        sceneBox.scene = nil
    }

    @MainActor
    public func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        let scene = sceneBox.scene
        return AnyView(BookPlayModePluginRootView(scene: scene, content: content))
    }


    private final class SceneBox {
        weak var scene: (any SceneProviding)?
    }
}
