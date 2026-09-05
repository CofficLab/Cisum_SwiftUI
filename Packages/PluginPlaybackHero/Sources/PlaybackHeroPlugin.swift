import CisumUIComponents
import KernelCore
import ProviderDocsView
import ProviderPlayback
import SwiftUI

/// 播放封面插件：向播放控制区注入封面/标题区视图（`setHeroView`）。
public actor PlaybackHeroPlugin: SuperPlugin {
    public static let shared = PlaybackHeroPlugin()
    public static let metadata = PluginMetadata(
        displayName: String(localized: "Playback Cover", bundle: .module),
        description: String(localized: "Provides the cover and title view for the player control area.", bundle: .module),
        iconName: "photo",
        order: 19,
        policy: .alwaysOn,
        category: .playback,
        version: "1.0.0"
    )

    nonisolated(unsafe) private weak var kernel: CisumKernel?
    nonisolated(unsafe) private var viewModel: PlaybackHeroViewModel?
    nonisolated(unsafe) private var observer: PlaybackHeroObserver?

    @MainActor
    public func onRegister(kernel: CisumKernel) async throws {
        if let docs = kernel.docs {
            docs.addAbout(DocsEntry(id: self.id, name: Self.metadata.displayName) { PlaybackHeroPluginAboutView() })
            docs.addManual(DocsEntry(id: self.id, name: Self.metadata.displayName) { PlaybackHeroPluginManualView() })
        }
    }

    @MainActor
    public func onBoot(kernel: CisumKernel) async throws {
        self.kernel = kernel
    }

    @MainActor
    public func onReady(kernel: CisumKernel) async throws {
        installState(kernel: kernel)
    }

    @MainActor
    public func onShutdown(kernel: CisumKernel) async throws {
        observer?.cancel()
        observer = nil
        viewModel = nil
        self.kernel = nil
    }

    /// 向 `ControlViewProviding` 注入封面/标题区视图。
    @MainActor
    public func addHeroView() -> AnyView? {
        installState(kernel: kernel)
        guard let viewModel else { return nil }
        return AnyView(PlaybackHeroView(viewModel: viewModel))
    }

    @MainActor
    private func installState(kernel: CisumKernel?) {
        guard viewModel == nil else { return }
        guard let playback = kernel?.playback else { return }
        let capability = PlaybackHeroPlaybackCapabilityAdapter(playback: playback)
        let viewModel = PlaybackHeroViewModel(playbackCapability: capability)
        self.viewModel = viewModel
        observer = PlaybackHeroObserver(playback: playback, viewModel: viewModel)
    }
}
