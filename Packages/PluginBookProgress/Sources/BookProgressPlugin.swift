import KernelCore
import OSLog
import ProviderDocsView
import CisumUIComponents
import PluginBook
import PluginBookScene
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
        return AnyView(BookProgressPluginRootView(scene: scene, viewModel: viewModel, content: content))
    }

    // MARK: - State assembly

    @MainActor
    private func installState() {
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
        let observer = BookProgressObserver(viewModel: viewModel)
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
        installState()
        return progressViewModel!
    }

    private final class SceneBox {
        weak var scene: (any SceneProviding)?
    }
}
