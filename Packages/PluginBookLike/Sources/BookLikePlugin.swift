import KernelCore
import ProviderDocsView
import CisumUIComponents
import PluginBookScene
import ProviderScene
import SwiftUI

public actor BookLikePlugin: SuperPlugin {
    public static let shared = BookLikePlugin()
    public static let metadata = PluginMetadata(
        displayName: BookLikePluginInfo.title,
        description: BookLikePluginInfo.description,
        iconName: BookLikePluginInfo.iconName,
        order: BookLikePluginInfo.order,
        policy: .disabled,
        category: .like,
    )

    nonisolated(unsafe) private let sceneBox = SceneBox()
    nonisolated(unsafe) private var likeViewModel: BookLikeViewModel?
    nonisolated(unsafe) private var likeObserver: BookLikeObserver?

    @MainActor
    public func onRegister(kernel: CisumKernel) async throws {
        if let docs = kernel.docs {
            docs.addAbout(DocsEntry(id: self.id, name: Self.metadata.displayName) { BookLikePluginAboutView() })
            docs.addManual(DocsEntry(id: self.id, name: Self.metadata.displayName) { BookLikePluginManualView() })
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
        return AnyView(BookLikePluginRootView(scene: scene, content: content))
    }

    @MainActor
    public func addSettingView() -> AnyView? {
        nil
    }

    @MainActor
    public func addSettingNavigationItem() -> PluginSettingNavigationItem? {
        let viewModel = resolveViewModel()
        return PluginSettingNavigationItem(
            id: "liked-books",
            title: String(localized: "Liked Books", bundle: .module),
            description: Self.metadata.description,
            iconName: Self.metadata.iconName,
            order: Self.metadata.order,
            destination: AnyView(BookLikeSettingsView(viewModel: viewModel))
        )
    }

    // MARK: - State assembly

    @MainActor
    private func installState() {
        guard likeViewModel == nil else { return }
        let viewModel = BookLikeViewModel()
        let observer = BookLikeObserver(viewModel: viewModel)
        likeViewModel = viewModel
        likeObserver = observer
    }

    @MainActor
    private func teardownState() {
        likeObserver?.cancel()
        likeObserver = nil
        likeViewModel = nil
    }

    @MainActor
    private func resolveViewModel() -> BookLikeViewModel {
        if let likeViewModel {
            return likeViewModel
        }
        installState()
        return likeViewModel!
    }

    private final class SceneBox {
        weak var scene: (any SceneProviding)?
    }
}
