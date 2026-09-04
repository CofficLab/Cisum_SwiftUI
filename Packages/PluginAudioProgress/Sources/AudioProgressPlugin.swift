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

    nonisolated(unsafe) private let sceneBox = SceneBox()
    nonisolated(unsafe) private var progressViewModel: AudioProgressViewModel?
    nonisolated(unsafe) private var progressObserver: AudioProgressObserver?

    @MainActor
    public func onRegister(kernel: CisumKernel) async throws {
        if let docs = kernel.docs {
            docs.addAbout(DocsEntry(id: self.id, name: Self.metadata.displayName) { AudioProgressPluginAboutView() })
            docs.addManual(DocsEntry(id: self.id, name: Self.metadata.displayName) { AudioProgressPluginManualView() })
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
        return AnyView(AudioProgressPluginRootView(scene: scene, viewModel: viewModel, content: content))
    }

    // MARK: - State assembly

    @MainActor
    private func installState() {
        guard progressViewModel == nil else { return }
        let viewModel = AudioProgressViewModel(
            audioScene: .music,
            audioRepo: { await AudioPlugin.getAudioRepoAsync() },
            saveWidgetData: { title, artist, isPlaying, coverArt in
                AudioProgressHost.saveWidgetData(title: title, artist: artist, isPlaying: isPlaying, coverArt: coverArt)
            }
        )
        let observer = AudioProgressObserver(
            viewModel: viewModel,
            storageResetNotifications: [Notification.Name("storageLocationDidReset")]
        )
        progressViewModel = viewModel
        progressObserver = observer
    }

    @MainActor
    private func teardownState() {
        progressObserver?.cancel()
        progressObserver = nil
        progressViewModel = nil
    }

    @MainActor
    private func resolveViewModel() -> AudioProgressViewModel {
        if let progressViewModel {
            return progressViewModel
        }
        installState()
        return progressViewModel!
    }

    private final class SceneBox {
        weak var scene: (any SceneProviding)?
    }
}
