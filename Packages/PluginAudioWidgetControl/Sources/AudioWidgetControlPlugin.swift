import CisumUIComponents
import KernelCore
import ProviderDocsView
import PluginAudio
import ProviderPlayback
import SwiftUI

public actor AudioWidgetControlPlugin: SuperPlugin {
    public static let shared = AudioWidgetControlPlugin()
    public static let metadata = PluginMetadata(
        displayName: AudioWidgetControlPluginInfo.title,
        description: AudioWidgetControlPluginInfo.description,
        iconName: AudioWidgetControlPluginInfo.iconName,
        order: 100,
        category: .tool,
    )

    nonisolated(unsafe) private weak var kernel: CisumKernel?
    nonisolated(unsafe) private var widgetViewModel: AudioWidgetControlViewModel?
    nonisolated(unsafe) private var widgetObserver: AudioWidgetCommandObserver?

    @MainActor
    public func onRegister(kernel: CisumKernel) async throws {
        if let docs = kernel.docs {
            docs.addAbout(DocsEntry(id: self.id, name: Self.metadata.displayName) { AudioWidgetControlPluginAboutView() })
            docs.addManual(DocsEntry(id: self.id, name: Self.metadata.displayName) { AudioWidgetControlPluginManualView() })
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
    public func onEnable(kernel: CisumKernel) async throws {
        self.kernel = kernel
        installState(kernel: kernel)
    }

    @MainActor
    public func onDisable(kernel: CisumKernel) async throws {
        teardownState()
    }

    @MainActor
    public func onShutdown(kernel: CisumKernel) async throws {
        teardownState()
        self.kernel = nil
    }

    public nonisolated var label: String { "widgetControl" }

    @MainActor
    public func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        let viewModel = resolveViewModel()
        return AnyView(
            content()
                .background(
                    AudioWidgetControlRootView(viewModel: viewModel)
                )
        )
    }

    // MARK: - State assembly

    @MainActor
    private func installState(kernel: CisumKernel?) {
        guard widgetViewModel == nil else { return }
        let viewModel = AudioWidgetControlViewModel(
            playbackCapability: makePlaybackCapability(from: kernel?.playback),
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
        let observer = AudioWidgetCommandObserver(viewModel: viewModel)
        widgetViewModel = viewModel
        widgetObserver = observer
    }

    @MainActor
    private func teardownState() {
        widgetObserver?.cancel()
        widgetObserver = nil
        widgetViewModel = nil
    }

    @MainActor
    private func resolveViewModel() -> AudioWidgetControlViewModel {
        if let widgetViewModel {
            return widgetViewModel
        }
        installState(kernel: kernel)
        return widgetViewModel!
    }

    /// 将内核播放 Provider 收窄后注入 ViewModel。
    @MainActor
    private func makePlaybackCapability(
        from playback: (any PlaybackProviding)?
    ) -> (any AudioWidgetPlaybackCapability)? {
        guard let playback else { return nil }
        return AudioWidgetPlaybackCapabilityAdapter(playback: playback)
    }
}
