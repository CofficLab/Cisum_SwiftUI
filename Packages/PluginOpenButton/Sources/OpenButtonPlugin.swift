import CisumUIComponents
import KernelCore
import ProviderDocsView
import ProviderPlayback
import SwiftUI

public actor OpenButtonPlugin: SuperPlugin {
    public static let shared = OpenButtonPlugin()
    public static let metadata = PluginMetadata(
        displayName: String(localized: "Open Current", bundle: .module),
        description: OpenButtonPluginInfo.description,
        iconName: OpenButtonPluginInfo.iconName,
        category: .tool,
    )

    nonisolated(unsafe) private var viewModel: OpenButtonViewModel?
    nonisolated(unsafe) private var observer: OpenButtonObserver?


    @MainActor
    public func onRegister(kernel: CisumKernel) async throws {
        if let docs = kernel.docs {
            docs.addAbout(DocsEntry(id: self.id, name: Self.metadata.displayName) { OpenButtonPluginAboutView() })
            docs.addManual(DocsEntry(id: self.id, name: Self.metadata.displayName) { OpenButtonPluginManualView() })
        }
    }

    @MainActor
    public func onBoot(kernel: CisumKernel) async throws {
        guard let playback = kernel.resolveProvider((any PlaybackProviding).self) else {
            throw CisumKernelError.serviceNotAvailable(service: "PlaybackProviding")
        }
        let viewModel = OpenButtonViewModel()
        self.viewModel = viewModel
        observer = OpenButtonObserver(playback: playback, viewModel: viewModel)
    }

    @MainActor
    public func onShutdown(kernel: CisumKernel) async throws {
        observer?.cancel()
        observer = nil
        viewModel = nil
    }

    #if os(macOS)
        @MainActor
        public func addToolBarButtons() -> [(id: String, view: AnyView)] {
            guard let viewModel else { return [] }
            return [(id: OpenButtonPluginInfo.toolbarItemId, view: AnyView(OpenCurrentButtonView(viewModel: viewModel)))]
        }
    #endif
}
