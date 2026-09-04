import CisumUIComponents
import KernelCore
import ProviderDocsView
import PluginBook
import SwiftUI

public actor BookSettingsPlugin: SuperPlugin {
    public static let shared = BookSettingsPlugin()
    public static let metadata = PluginMetadata(
        displayName: BookSettingsPluginInfo.title,
        description: BookSettingsPluginInfo.description,
        iconName: BookSettingsPluginInfo.iconName,
        order: BookSettingsPluginInfo.order,
        category: .settings,
    )

    nonisolated(unsafe) private var settingsViewModel: BookSettingsViewModel?
    nonisolated(unsafe) private var settingsObserver: BookSettingsObserver?

    @MainActor
    public func onRegister(kernel: CisumKernel) async throws {
        if let docs = kernel.docs {
            docs.addAbout(DocsEntry(id: self.id, name: Self.metadata.displayName) { BookSettingsPluginAboutView() })
            docs.addManual(DocsEntry(id: self.id, name: Self.metadata.displayName) { BookSettingsPluginManualView() })
        }
    }

    @MainActor
    public func onBoot(kernel: CisumKernel) async throws {
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
        teardownState()
    }

    @MainActor
    public func addSettingNavigationItem() -> PluginSettingNavigationItem? {
        let viewModel = resolveViewModel()
        return PluginSettingNavigationItem(
            id: "book-settings",
            title: BookSettingsPluginInfo.title,
            description: Self.metadata.description,
            iconName: "book",
            order: BookSettingsPluginInfo.order,
            destination: AnyView(BookSettingsPluginView(viewModel: viewModel))
        )
    }

    // MARK: - State assembly

    @MainActor
    private func installState() {
        guard settingsViewModel == nil else { return }
        let viewModel = BookSettingsViewModel()
        let observer = BookSettingsObserver(viewModel: viewModel)
        settingsViewModel = viewModel
        settingsObserver = observer
    }

    @MainActor
    private func teardownState() {
        settingsObserver?.cancel()
        settingsObserver = nil
        settingsViewModel = nil
    }

    @MainActor
    private func resolveViewModel() -> BookSettingsViewModel {
        if let settingsViewModel {
            return settingsViewModel
        }
        installState()
        return settingsViewModel!
    }
}
