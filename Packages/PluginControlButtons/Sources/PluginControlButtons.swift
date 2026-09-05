import CisumUIComponents
import KernelCore
import ProviderDocsView
import ProviderPlayback
import ProviderRootView
import SwiftUI

/// 播放控制按钮插件：向播放控制区注入底部控制按钮组
/// （更多 / 上一曲 / 播放暂停 / 下一曲 / 播放模式）。
public actor ControlButtonsPlugin: SuperPlugin {
    public static let shared = ControlButtonsPlugin()
    public static let metadata = PluginMetadata(
        displayName: String(localized: "Playback Control Buttons", bundle: .module),
        description: String(localized: "Provides the previous / play / next control buttons at the bottom of the player.", bundle: .module),
        iconName: "playpause.fill",
        order: 20,
        policy: .alwaysOn,
        category: .playback,
        version: "1.0.0"
    )

    nonisolated(unsafe) private weak var kernel: CisumKernel?
    nonisolated(unsafe) private var viewModel: ControlButtonsViewModel?
    nonisolated(unsafe) private var observer: ControlButtonsObserver?

    @MainActor
    public func onRegister(kernel: CisumKernel) async throws {
        self.kernel = kernel
        if let docs = kernel.docs {
            docs.addAbout(DocsEntry(id: self.id, name: Self.metadata.displayName) { PluginControlButtonsAboutView() })
            docs.addManual(DocsEntry(id: self.id, name: Self.metadata.displayName) { PluginControlButtonsManualView() })
        }
    }

    @MainActor
    public func onBoot(kernel: CisumKernel) async throws {
        guard let playback = kernel.resolveProvider((any PlaybackProviding).self) else {
            throw CisumKernelError.serviceNotAvailable(service: "PlaybackProviding")
        }
        let viewModel = ControlButtonsViewModel()
        self.viewModel = viewModel
        observer = ControlButtonsObserver(playback: playback, viewModel: viewModel)
    }

    @MainActor
    public func onShutdown(kernel: CisumKernel) async throws {
        observer?.cancel()
        observer = nil
        viewModel = nil
    }

    /// 向 `ControlViewProviding` 注入播放控制按钮组。
    @MainActor
    public func addControlButtonsView() -> AnyView? {
        AnyView(
            ControlButtonsView(viewModel: viewModel ?? ControlButtonsViewModel()) { [weak self] in
                guard let kernel = self?.kernel else { return }
                kernel.resolveProvider((any RootViewProviding).self)?.toggleContentView()
            }
        )
    }
}
