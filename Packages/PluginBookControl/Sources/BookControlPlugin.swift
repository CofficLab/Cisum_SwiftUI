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
        sceneBox.scene = scene
        installState()
    }

    @MainActor
    public func onEnable(kernel: CisumKernel) async throws {
        installState()
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
        let scene = sceneBox.scene
        let viewModel = resolveViewModel()
        return AnyView(BookControlPluginRootView(scene: scene, viewModel: viewModel, content: content))
    }

    // MARK: - State assembly

    @MainActor
    private func installState() {
        guard controlViewModel == nil else { return }
        let viewModel = BookControlViewModel(targetScene: .audiobooks)
        let observer = BookControlObserver(viewModel: viewModel)
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
        installState()
        return controlViewModel!
    }

    private final class SceneBox {
        weak var scene: (any SceneProviding)?
    }
}
