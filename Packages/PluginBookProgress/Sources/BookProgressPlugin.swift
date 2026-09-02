import CisumKernel
import CisumUIComponents
import PluginBook
import PluginBookScene
import ProviderScene
import SwiftData
import SwiftUI

public actor BookProgressPlugin: SuperPlugin, CisumKernelPlugin {
    public static let shared = BookProgressPlugin()
    public static let metadata = PluginMetadata(
        displayName: BookProgressPluginInfo.title,
        description: BookProgressPluginInfo.description,
        iconName: BookProgressPluginInfo.iconName,
        order: BookProgressPluginInfo.order
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
        return AnyView(BookProgressPluginRootView(scene: scene, content: content))
    }


    private final class SceneBox {
        weak var scene: (any SceneProviding)?
    }
}
