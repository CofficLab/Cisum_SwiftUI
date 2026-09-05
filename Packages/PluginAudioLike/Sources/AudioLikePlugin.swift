import KernelCore
import ProviderDocsView
import CisumUIComponents
import PluginAudioScene
import ProviderPlayback
import ProviderScene
import SwiftUI

public actor AudioLikePlugin: SuperPlugin {
    public static let shared = AudioLikePlugin()
    public static let metadata = PluginMetadata(
        displayName: AudioLikePluginInfo.title,
        description: AudioLikePluginInfo.description,
        iconName: AudioLikePluginInfo.iconName,
        order: AudioLikePluginInfo.order,
        policy: .disabled,
        category: .like,
    )

    nonisolated(unsafe) private let sceneBox = SceneBox()
    nonisolated(unsafe) private var viewModel: AudioLikeViewModel?
    nonisolated(unsafe) private var observer: AudioLikeObserver?

    @MainActor
    public func onRegister(kernel: CisumKernel) async throws {
        if let docs = kernel.docs {
            docs.addAbout(DocsEntry(id: self.id, name: Self.metadata.displayName) { AudioLikePluginAboutView() })
            docs.addManual(DocsEntry(id: self.id, name: Self.metadata.displayName) { AudioLikePluginManualView() })
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
        return AnyView(AudioLikePluginRootView(viewModel: viewModel, content: content))
    }

    @MainActor
    public func addSettingView() -> AnyView? {
        nil
    }

    @MainActor
    public func addSettingNavigationItem() -> PluginSettingNavigationItem? {
        let viewModel = resolveViewModel()
        return PluginSettingNavigationItem(
            id: "liked-audio",
            title: String(localized: "Liked audio", bundle: .module),
            description: Self.metadata.description,
            iconName: Self.metadata.iconName,
            order: Self.metadata.order,
            destination: AnyView(AudioLikeSettingsView(viewModel: viewModel))
        )
    }

    // MARK: - State assembly

    @MainActor
    private func installState(scene: any SceneProviding, playback: any PlaybackProviding) {
        guard viewModel == nil else { return }
        let viewModel = AudioLikeViewModel()
        let observer = AudioLikeObserver(scene: scene, playback: playback, viewModel: viewModel)
        self.viewModel = viewModel
        self.observer = observer
    }

    @MainActor
    private func teardownState() {
        observer?.cancel()
        observer = nil
        viewModel = nil
    }

    @MainActor
    private func resolveViewModel() -> AudioLikeViewModel {
        if let viewModel {
            return viewModel
        }
        let viewModel = AudioLikeViewModel()
        self.viewModel = viewModel
        return viewModel
    }

    private final class SceneBox {
        weak var scene: (any SceneProviding)?
    }
}
