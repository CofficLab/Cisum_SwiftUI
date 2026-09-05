import KernelCore
import ProviderDocsView
import CisumUIComponents
import PluginBookScene
import ProviderPlayback
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

    nonisolated(unsafe) private let sceneBox = SceneBox()
    nonisolated(unsafe) private var controlViewModel: BookControlViewModel?
    nonisolated(unsafe) private var controlObserver: BookControlObserver?

    @MainActor
    public func onRegister(kernel: CisumKernel) async throws {
        if let docs = kernel.docs {
            docs.addAbout(DocsEntry(id: self.id, name: Self.metadata.displayName) { BookControlPluginAboutView() })
            docs.addManual(DocsEntry(id: self.id, name: Self.metadata.displayName) { BookControlPluginManualView() })
        }
    }

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
    public func onEnable(kernel: CisumKernel) async throws {
        guard let scene = kernel.resolveProvider((any SceneProviding).self),
              let playback = kernel.resolveProvider((any PlaybackProviding).self) else { return }
        sceneBox.scene = scene
        installState(scene: scene, playback: playback)
    }

    @MainActor
    public func onDisable(kernel: CisumKernel) async throws {
        teardownState()
    }

    @MainActor
    public func onShutdown(kernel: CisumKernel) async throws {
        sceneBox.scene = nil
        teardownState()
    }

    @MainActor
    public func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        let viewModel = resolveViewModel()
        return AnyView(BookControlPluginRootView(viewModel: viewModel, content: content))
    }

    // MARK: - State assembly

    @MainActor
    private func installState(scene: any SceneProviding, playback: any PlaybackProviding) {
        guard controlObserver == nil else { return }
        let viewModel = controlViewModel ?? BookControlViewModel(targetScene: .audiobooks)
        let observer = BookControlObserver(scene: scene, playback: playback, viewModel: viewModel)
        controlViewModel = viewModel
        controlObserver = observer
    }

    @MainActor
    private func teardownState() {
        controlObserver?.cancel()
        controlObserver = nil
        controlViewModel = nil
    }

    @MainActor
    private func resolveViewModel() -> BookControlViewModel {
        if let controlViewModel {
            return controlViewModel
        }
        let viewModel = BookControlViewModel(targetScene: .audiobooks)
        controlViewModel = viewModel
        return viewModel
    }

    private final class SceneBox {
        weak var scene: (any SceneProviding)?
    }
}
