import KernelCore
import ProviderDocsView
import CisumUIComponents
import PluginAudio
import PluginAudioScene
import ProviderPlayback
import ProviderScene
import SwiftUI

public actor AudioControlPlugin: SuperPlugin {
    public static let shared = AudioControlPlugin()
    public static let metadata = PluginMetadata(
        displayName: AudioControlPluginInfo.title,
        description: AudioControlPluginInfo.description,
        iconName: AudioControlPluginInfo.iconName,
        category: .playback,
    )

    nonisolated(unsafe) private let sceneBox = SceneBox()
    nonisolated(unsafe) private weak var kernel: CisumKernel?
    nonisolated(unsafe) private var controlViewModel: AudioControlViewModel?
    nonisolated(unsafe) private var controlObserver: AudioControlObserver?

    @MainActor
    public func onRegister(kernel: CisumKernel) async throws {
        if let docs = kernel.docs {
            docs.addAbout(DocsEntry(id: self.id, name: Self.metadata.displayName) { AudioControlPluginAboutView() })
            docs.addManual(DocsEntry(id: self.id, name: Self.metadata.displayName) { AudioControlPluginManualView() })
        }
    }

    @MainActor
    public func onBoot(kernel: CisumKernel) async throws {
        self.kernel = kernel
        // 跨插件 Provider（Scene / Playback）在 onReady 中解析，
        // 不假设其他插件已完成 Provider 注册。
    }

    /// 所有 Provider 插件完成 onBoot 后再组装依赖它们的 ViewModel 与 Observer。
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
        sceneBox.scene = nil
        teardownState()
    }

    @MainActor
    public func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        let viewModel = resolveViewModel()
        return AnyView(AudioControlPluginRootView(viewModel: viewModel, content: content))
    }

    // MARK: - State assembly

    /// 创建并持有播放控制 ViewModel 与观察者（幂等）。
    @MainActor
    private func installState(kernel: CisumKernel) {
        guard controlViewModel == nil else { return }

        guard let scene = kernel.resolveProvider((any SceneProviding).self),
              let playback = kernel.resolveProvider((any PlaybackProviding).self) else { return }
        sceneBox.scene = scene

        let viewModel = AudioControlViewModel(
            targetScene: .music,
            playbackCapability: makePlaybackCapability(from: playback),
            nextAsset: makeNextAssetProvider(),
            previousAsset: makePreviousAssetProvider(),
            firstAsset: makeFirstAssetProvider(),
            lastAsset: makeLastAssetProvider()
        )
        let observer = AudioControlObserver(scene: scene, playback: playback, viewModel: viewModel)
        controlViewModel = viewModel
        controlObserver = observer
    }

    @MainActor
    private func teardownState() {
        controlObserver?.cancel()
        controlObserver = nil
        controlViewModel = nil
    }

    /// 返回当前持有的 ViewModel；若尚未安装（启动前或插件被禁用），
    /// 提供临时实例保证 View 贡献可用。
    @MainActor
    private func resolveViewModel() -> AudioControlViewModel {
        if let controlViewModel {
            return controlViewModel
        }
        let viewModel = AudioControlViewModel(
            targetScene: .music,
            playbackCapability: makePlaybackCapability(from: kernel?.playback),
            nextAsset: makeNextAssetProvider(),
            previousAsset: makePreviousAssetProvider(),
            firstAsset: makeFirstAssetProvider(),
            lastAsset: makeLastAssetProvider()
        )
        controlViewModel = viewModel
        return viewModel
    }

    /// 将内核能力收窄后注入 ViewModel；ViewModel 不持有 Kernel。
    @MainActor
    private func makePlaybackCapability(
        from playback: (any PlaybackProviding)?
    ) -> (any AudioControlPlaybackCapability)? {
        guard let playback else { return nil }
        return AudioControlPlaybackCapabilityAdapter(playback: playback)
    }

    @MainActor
    private func makeNextAssetProvider() -> AudioControlAdjacentAssetProvider {
        { @MainActor current, verbose in
            guard let repo = await AudioPlugin.getAudioRepoAsync() else {
                throw AudioPluginError.hostNotConfigured
            }
            return try await repo.getNextOf(current, verbose: verbose)
        }
    }

    @MainActor
    private func makePreviousAssetProvider() -> AudioControlAdjacentAssetProvider {
        { @MainActor current, verbose in
            guard let repo = await AudioPlugin.getAudioRepoAsync() else {
                throw AudioPluginError.hostNotConfigured
            }
            return try await repo.getPrevOf(current, verbose: verbose)
        }
    }

    @MainActor
    private func makeFirstAssetProvider() -> AudioControlFirstAssetProvider {
        { @MainActor in
            guard let repo = await AudioPlugin.getAudioRepoAsync() else {
                throw AudioPluginError.hostNotConfigured
            }
            return try await repo.getFirst()
        }
    }

    @MainActor
    private func makeLastAssetProvider() -> AudioControlLastAssetProvider {
        { @MainActor in
            guard let repo = await AudioPlugin.getAudioRepoAsync() else {
                throw AudioPluginError.hostNotConfigured
            }
            return try await repo.getLast()
        }
    }

    private final class SceneBox {
        weak var scene: (any SceneProviding)?
    }
}
