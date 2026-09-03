import KernelCore
import ProviderDocsView
import CisumUIComponents
import PluginAudio
import PluginAudioScene
import ProviderScene
import SwiftUI

public actor AudioPlayModePlugin: SuperPlugin {
    public static let shared = AudioPlayModePlugin()
    public static let metadata = PluginMetadata(
        displayName: AudioPlayModePluginInfo.title,
        description: AudioPlayModePluginInfo.description,
        iconName: AudioPlayModePluginInfo.iconName,
        order: AudioPlayModePluginInfo.order,
        category: .playback,
    )


    @MainActor
    public func onRegister(kernel: CisumKernel) async throws {
        if let docs = kernel.docs {
            docs.addAbout(DocsEntry(id: self.id, name: Self.metadata.displayName) { AudioPlayModePluginAboutView() })
            docs.addManual(DocsEntry(id: self.id, name: Self.metadata.displayName) { AudioPlayModePluginManualView() })
        }
    }

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
        return AnyView(AudioPlayModePluginRootView(scene: scene, content: content))
    }


    private final class SceneBox {
        weak var scene: (any SceneProviding)?
    }
}
