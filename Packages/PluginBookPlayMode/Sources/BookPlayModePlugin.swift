import KernelCore
import ProviderDocsView
import CisumUIComponents
import PluginBookScene
import ProviderPlayback
import ProviderScene
import SwiftUI

public actor BookPlayModePlugin: SuperPlugin {
    public static let shared = BookPlayModePlugin()
    public static let metadata = PluginMetadata(
        displayName: BookPlayModePluginInfo.title,
        description: BookPlayModePluginInfo.description,
        iconName: BookPlayModePluginInfo.iconName,
        order: BookPlayModePluginInfo.order,
        category: .playback,
    )


    @MainActor
    public func onRegister(kernel: CisumKernel) async throws {
        if let docs = kernel.docs {
            docs.addAbout(DocsEntry(id: self.id, name: Self.metadata.displayName) { BookPlayModePluginAboutView() })
            docs.addManual(DocsEntry(id: self.id, name: Self.metadata.displayName) { BookPlayModePluginManualView() })
        }
    }

    nonisolated(unsafe) private let sceneBox = SceneBox()
    nonisolated(unsafe) private var viewModel: BookPlayModeViewModel?
    nonisolated(unsafe) private var observer: BookPlayModeObserver?

    @MainActor
    public func onBoot(kernel: CisumKernel) async throws {
        guard let scene = kernel.resolveProvider((any SceneProviding).self) else {
            throw CisumKernelError.serviceNotAvailable(service: "SceneProviding")
        }
        guard let playback = kernel.resolveProvider((any PlaybackProviding).self) else {
            throw CisumKernelError.serviceNotAvailable(service: "PlaybackProviding")
        }
        sceneBox.scene = scene
        installState(scene: scene, playback: playback)
    }

    @MainActor
    public func onShutdown(kernel: CisumKernel) async throws {
        sceneBox.scene = nil
        observer?.cancel()
        observer = nil
        viewModel = nil
    }

    @MainActor
    public func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        return AnyView(BookPlayModePluginRootView(content: content))
    }

    @MainActor
    private func installState(scene: any SceneProviding, playback: any PlaybackProviding) {
        guard viewModel == nil else { return }
        let viewModel = BookPlayModeViewModel()
        self.viewModel = viewModel
        observer = BookPlayModeObserver(scene: scene, playback: playback, viewModel: viewModel)
    }


    private final class SceneBox {
        weak var scene: (any SceneProviding)?
    }
}
