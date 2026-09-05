import KernelCore
import ProviderDocsView
import CisumUIComponents
import PluginAudio
import PluginAudioScene
import ProviderPlayback
import ProviderScene
import SwiftUI

public actor AudioControlPlugin: SuperPlugin {
    public static let shared = AudioControlPlugin()
    public static let metadata = PluginMetadata(
        displayName: AudioControlPluginInfo.title,
        description: AudioControlPluginInfo.description,
        iconName: AudioControlPluginInfo.iconName,
        category: .playback,
    )

    nonisolated(unsafe) private let sceneBox = SceneBox()
    nonisolated(unsafe) private var controlViewModel: AudioControlViewModel?
    nonisolated(unsafe) private var controlObserver: AudioControlObserver?

    @MainActor
    public func onRegister(kernel: CisumKernel) async throws {
        if let docs = kernel.docs {
            docs.addAbout(DocsEntry(id: self.id, name: Self.metadata.displayName) { AudioControlPluginAboutView() })
            docs.addManual(DocsEntry(id: self.id, name: Self.metadata.displayName) { AudioControlPluginManualView() })
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
        return AnyView(AudioControlPluginRootView(viewModel: viewModel, content: content))
    }

    // MARK: - State assembly

    @MainActor
    private func installState(scene: any SceneProviding, playback: any PlaybackProviding) {
        guard controlViewModel == nil else { return }
        let viewModel = AudioControlViewModel(
            targetScene: .music,
            nextAsset: { current, verbose in
                guard let repo = await AudioPlugin.getAudioRepoAsync() else {
                    throw AudioPluginError.hostNotConfigured
                }
                return try await repo.getNextOf(current, verbose: verbose)
            },
            previousAsset: { current, verbose in
                guard let repo = await AudioPlugin.getAudioRepoAsync() else {
                    throw AudioPluginError.hostNotConfigured
                }
                return try await repo.getPrevOf(current, verbose: verbose)
            },
            firstAsset: {
                guard let repo = await AudioPlugin.getAudioRepoAsync() else {
                    throw AudioPluginError.hostNotConfigured
                }
                return try await repo.getFirst()
            },
            lastAsset: {
                guard let repo = await AudioPlugin.getAudioRepoAsync() else {
                    throw AudioPluginError.hostNotConfigured
                }
                return try await repo.getLast()
            }
        )
        let observer = AudioControlObserver(scene: scene, playback: playback, viewModel: viewModel)
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
    private func resolveViewModel() -> AudioControlViewModel {
        if let controlViewModel {
            return controlViewModel
        }
        let viewModel = AudioControlViewModel(
            targetScene: .music,
            nextAsset: { current, verbose in
                guard let repo = await AudioPlugin.getAudioRepoAsync() else {
                    throw AudioPluginError.hostNotConfigured
                }
                return try await repo.getNextOf(current, verbose: verbose)
            },
            previousAsset: { current, verbose in
                guard let repo = await AudioPlugin.getAudioRepoAsync() else {
                    throw AudioPluginError.hostNotConfigured
                }
                return try await repo.getPrevOf(current, verbose: verbose)
            },
            firstAsset: {
                guard let repo = await AudioPlugin.getAudioRepoAsync() else {
                    throw AudioPluginError.hostNotConfigured
                }
                return try await repo.getFirst()
            },
            lastAsset: {
                guard let repo = await AudioPlugin.getAudioRepoAsync() else {
                    throw AudioPluginError.hostNotConfigured
                }
                return try await repo.getLast()
            }
        )
        controlViewModel = viewModel
        return viewModel
    }

    private final class SceneBox {
        weak var scene: (any SceneProviding)?
    }
}
