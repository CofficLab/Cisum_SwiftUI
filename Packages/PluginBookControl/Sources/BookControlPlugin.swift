import KernelCore
import ProviderDocsView
import CisumUIComponents
import PluginBookScene
import ProviderScene
import SwiftUI

public actor BookControlPlugin: SuperPlugin {
    public static let shared = BookControlPlugin()
    public static let metadata = PluginMetadata(
        displayName: BookControlPluginInfo.title,
        description: BookControlPluginInfo.description,
        iconName: BookControlPluginInfo.iconName,
        order: BookControlPluginInfo.order,
        category: .playback,
    )


    @MainActor
    public func onRegister(kernel: CisumKernel) async throws {
        if let docs = kernel.docs {
            docs.addAbout(DocsEntry(id: self.id, name: Self.metadata.displayName) { BookControlPluginAboutView() })
            docs.addManual(DocsEntry(id: self.id, name: Self.metadata.displayName) { BookControlPluginManualView() })
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
        return AnyView(BookControlPluginRootView(scene: scene, content: content))
    }


    private final class SceneBox {
        weak var scene: (any SceneProviding)?
    }
}
