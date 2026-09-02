import CisumKernel
import CisumUIComponents
import ProviderScene
import SwiftUI

public actor AudioDownloadPlugin: SuperPlugin, CisumKernelPlugin {
    public static let shared = AudioDownloadPlugin()
    public static let metadata = PluginMetadata(
        displayName: AudioDownloadPluginInfo.title,
        description: AudioDownloadPluginInfo.description,
        iconName: AudioDownloadPluginInfo.iconName,
        order: AudioDownloadPluginInfo.order
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
        return AnyView(AudioDownloadPluginRootView(scene: scene) { content() })
    }


    private final class SceneBox {
        weak var scene: (any SceneProviding)?
    }
}
