import KernelCore
import ProviderDocsView
import CisumUIComponents
import PluginAudio
import PluginAudioScene
import ProviderScene
import SwiftUI

public actor AudioProgressPlugin: SuperPlugin, SuperLog {
    public static let shared = AudioProgressPlugin()
    public nonisolated static let emoji = "💾"
    public static let verbose = true
    public static let metadata = PluginMetadata(
        displayName: String(localized: String.LocalizationValue(AudioProgressPluginInfo.titleKey), bundle: .module),
        description: String(localized: String.LocalizationValue(AudioProgressPluginInfo.descriptionKey), bundle: .module),
        iconName: "waveform",
        order: 0,
        category: .playback,
    )


    @MainActor
    public func onRegister(kernel: CisumKernel) async throws {
        if let docs = kernel.docs {
            docs.addAbout(DocsEntry(id: self.id, name: Self.metadata.displayName) { AudioProgressPluginAboutView() })
            docs.addManual(DocsEntry(id: self.id, name: Self.metadata.displayName) { AudioProgressPluginManualView() })
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
        return AnyView(AudioProgressPluginRootView(scene: scene, content: content))
    }


    private final class SceneBox {
        weak var scene: (any SceneProviding)?
    }
}
