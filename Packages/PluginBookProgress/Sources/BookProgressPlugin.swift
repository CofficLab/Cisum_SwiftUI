import KernelCore
import OSLog
import ProviderDocsView
import CisumUIComponents
import PluginBook
import PluginBookScene
import ProviderPlayback
import ProviderScene
import SwiftData
import SwiftUI

public actor BookProgressPlugin: SuperPlugin {
    public static let shared = BookProgressPlugin()
    public static let metadata = PluginMetadata(
        displayName: BookProgressPluginInfo.title,
        description: BookProgressPluginInfo.description,
        iconName: BookProgressPluginInfo.iconName,
        order: BookProgressPluginInfo.order,
        category: .playback,
    )

    nonisolated(unsafe) private let sceneBox = SceneBox()
    nonisolated(unsafe) private var progressViewModel: BookProgressViewModel?
    nonisolated(unsafe) private var progressObserver: BookProgressObserver?

    @MainActor
    public func onRegister(kernel: CisumKernel) async throws {
        if let docs = kernel.docs {
            docs.addAbout(DocsEntry(id: self.id, name: Self.metadata.displayName) { BookProgressPluginAboutView() })
            docs.addManual(DocsEntry(id: self.id, name: Self.metadata.displayName) { BookProgressPluginManualView() })
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
        return AnyView(BookProgressPluginRootView(viewModel: viewModel, content: content))
    }

    // MARK: - State assembly

    @MainActor
    private func installState(scene: any SceneProviding, playback: any PlaybackProviding) {
        guard progressViewModel == nil else { return }
        let viewModel = BookProgressViewModel(
            targetScene: .audiobooks,
            currentBookURL: { BookSettingRepo.getCurrent() },
            currentBookTime: { BookSettingRepo.getCurrentTime() },
            storeCurrentBookURL: { BookSettingRepo.storeCurrent($0) },
            storeCurrentBookTime: { BookSettingRepo.storeCurrentTime($0) },
            saveBookState: { bookURL, currentURL, time in
                do {
                    let dbRootURL = try await MainActor.run {
                        try BookPluginHost.getDBRootDir()
                    }
                    try await Task.detached(priority: .utility) {
                        let container = try BookConfig.getContainer(dbRootURL: dbRootURL)
                        try BookProgressStatePersistence.save(
                            bookURL: bookURL,
                            currentURL: currentURL,
                            time: time,
                            container: container
                        )
                    }
                } catch {
                    os_log(.error, "BookProgressPlugin failed to save book state: \(error.localizedDescription)")
                }
            }
        )
        let observer = BookProgressObserver(scene: scene, playback: playback, viewModel: viewModel)
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
    private func resolveViewModel() -> BookProgressViewModel {
        if let progressViewModel {
            return progressViewModel
        }
        let viewModel = BookProgressViewModel(
            targetScene: .audiobooks,
            currentBookURL: { BookSettingRepo.getCurrent() },
            currentBookTime: { BookSettingRepo.getCurrentTime() },
            storeCurrentBookURL: { BookSettingRepo.storeCurrent($0) },
            storeCurrentBookTime: { BookSettingRepo.storeCurrentTime($0) },
            saveBookState: { _, _, _ in }
        )
        progressViewModel = viewModel
        return viewModel
    }

    private final class SceneBox {
        weak var scene: (any SceneProviding)?
    }
}
