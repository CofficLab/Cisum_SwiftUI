import CisumUIComponents
import KernelCore
import ProviderDocsView
import ProviderPlayback
import SwiftUI

public actor LikeButtonPlugin: SuperPlugin {
    public static let shared = LikeButtonPlugin()
    public static let metadata = PluginMetadata(
        displayName: String(localized: "Like Button", bundle: .module),
        description: LikeButtonPluginInfo.description,
        iconName: LikeButtonPluginInfo.iconName,
        policy: .disabled,
        category: .like,
    )

    nonisolated(unsafe) private var viewModel: LikeButtonViewModel?
    nonisolated(unsafe) private var observer: LikeButtonObserver?


    @MainActor
    public func onRegister(kernel: CisumKernel) async throws {
        if let docs = kernel.docs {
            docs.addAbout(DocsEntry(id: self.id, name: Self.metadata.displayName) { LikeButtonPluginAboutView() })
            docs.addManual(DocsEntry(id: self.id, name: Self.metadata.displayName) { LikeButtonPluginManualView() })
        }
    }

    @MainActor
    public func onBoot(kernel: CisumKernel) async throws {
        guard let playback = kernel.resolveProvider((any PlaybackProviding).self) else {
            throw CisumKernelError.serviceNotAvailable(service: "PlaybackProviding")
        }
        let viewModel = LikeButtonViewModel()
        self.viewModel = viewModel
        observer = LikeButtonObserver(playback: playback, viewModel: viewModel)
    }

    @MainActor
    public func onShutdown(kernel: CisumKernel) async throws {
        observer?.cancel()
        observer = nil
        viewModel = nil
    }

    @MainActor
    public func addToolBarButtons() -> [(id: String, view: AnyView)] {
        guard let viewModel else { return [] }
        return [(id: LikeButtonPluginInfo.toolbarItemId, view: AnyView(LikeToggleButtonView(viewModel: viewModel)))]
    }
}
