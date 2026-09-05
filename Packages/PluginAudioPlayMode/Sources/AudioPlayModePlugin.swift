import KernelCore
import ProviderDocsView
import CisumUIComponents
import PluginAudio
import PluginAudioScene
import ProviderPlayback
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
    nonisolated(unsafe) private var viewModel: AudioPlayModeViewModel?
    nonisolated(unsafe) private var observer: AudioPlayModeObserver?

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
        return AnyView(AudioPlayModePluginRootView(content: content))
    }

    @MainActor
    private func installState(scene: any SceneProviding, playback: any PlaybackProviding) {
        guard viewModel == nil else { return }
        let viewModel = AudioPlayModeViewModel(
            sort: { currentURL in
                guard let repo = await AudioPlugin.getAudioRepoAsync() else {
                    throw AudioPluginError.hostNotConfigured
                }
                await repo.sort(currentURL, reason: "PlayModeChanged")
            },
            shuffle: { currentURL in
                guard let repo = await AudioPlugin.getAudioRepoAsync() else {
                    throw AudioPluginError.hostNotConfigured
                }
                try await repo.sortRandom(currentURL, reason: "PlayModeChanged", verbose: false)
            }
        )
        self.viewModel = viewModel
        observer = AudioPlayModeObserver(scene: scene, playback: playback, viewModel: viewModel)
    }


    private final class SceneBox {
        weak var scene: (any SceneProviding)?
    }
}
