import KernelCore
import ProviderDocsView
import CisumUIComponents
import ProviderPlayback
import ProviderScene
import SwiftUI

public actor AudioDownloadPlugin: SuperPlugin {
    public static let shared = AudioDownloadPlugin()
    public static let metadata = PluginMetadata(
        displayName: AudioDownloadPluginInfo.title,
        description: AudioDownloadPluginInfo.description,
        iconName: AudioDownloadPluginInfo.iconName,
        order: AudioDownloadPluginInfo.order,
        category: .playback,
    )


    @MainActor
    public func onRegister(kernel: CisumKernel) async throws {
        if let docs = kernel.docs {
            docs.addAbout(DocsEntry(id: self.id, name: Self.metadata.displayName) { AudioDownloadPluginAboutView() })
            docs.addManual(DocsEntry(id: self.id, name: Self.metadata.displayName) { AudioDownloadPluginManualView() })
        }
    }

    nonisolated(unsafe) private let sceneBox = SceneBox()
    nonisolated(unsafe) private var viewModel: AudioDownloadViewModel?
    nonisolated(unsafe) private var observer: AudioDownloadObserver?

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
        return AnyView(AudioDownloadPluginRootView(content: content))
    }

    @MainActor
    private func installState(scene: any SceneProviding, playback: any PlaybackProviding) {
        guard viewModel == nil else { return }
        let viewModel = AudioDownloadViewModel()
        self.viewModel = viewModel
        observer = AudioDownloadObserver(scene: scene, playback: playback, viewModel: viewModel)
    }


    private final class SceneBox {
        weak var scene: (any SceneProviding)?
    }
}
