import KernelCore
import ProviderDocsView
import CisumUIComponents
import OSLog
import ProviderPlayback
import ProviderRootView
import ProviderScene
import SwiftUI
import MagicKit

public actor BookControlButtonsPlugin: SuperPlugin, SuperLog {
    nonisolated static let verbose = true

    public static let shared = BookControlButtonsPlugin()
    public static let metadata = PluginMetadata(
        displayName: BookControlPluginInfo.title,
        description: BookControlPluginInfo.description,
        iconName: BookControlPluginInfo.iconName,
        order: BookControlPluginInfo.order,
        category: .playback,
    )

    nonisolated(unsafe) private weak var kernel: CisumKernel?
    nonisolated(unsafe) private var controlViewModel: BookControlViewModel?
    nonisolated(unsafe) private var controlObserver: BookControlObserver?

    @MainActor
    public func onRegister(kernel: CisumKernel) async throws {
        if Self.verbose { os_log("\(Self.t)🔌 onRegister") }
        if let docs = kernel.docs {
            docs.addAbout(DocsEntry(id: self.id, name: Self.metadata.displayName) { BookControlPluginAboutView() })
            docs.addManual(DocsEntry(id: self.id, name: Self.metadata.displayName) { BookControlPluginManualView() })
        }
    }

    @MainActor
    public func onBoot(kernel: CisumKernel) async throws {
        self.kernel = kernel
        if Self.verbose { os_log("\(Self.t)🚀 onBoot") }
        // 跨插件 Provider（Scene / Playback）在 onReady 中解析，
        // 不假设其他插件已完成 Provider 注册。
    }

    /// 所有 Provider 插件完成 onBoot 后再组装依赖它们的 ViewModel 与 Observer。
    @MainActor
    public func onReady(kernel: CisumKernel) async throws {
        if Self.verbose { os_log("\(Self.t)🟢 onReady") }
        installState(kernel: kernel)
    }

    @MainActor
    public func onEnable(kernel: CisumKernel) async throws {
        self.kernel = kernel
        if Self.verbose { os_log("\(Self.t)✅ onEnable") }
        installState(kernel: kernel)
    }

    @MainActor
    public func onDisable(kernel: CisumKernel) async throws {
        if Self.verbose { os_log("\(Self.t)⏹️ onDisable") }
        teardownState()
    }

    @MainActor
    public func onShutdown(kernel: CisumKernel) async throws {
        if Self.verbose { os_log("\(Self.t)🛑 onShutdown") }
        teardownState()
    }

    /// 仅在有声书场景向播放控制区注入书籍专用按钮。
    @MainActor
    public func addControlButtonsView() -> AnyView? {
        guard kernel?.scene?.currentScene == .audiobooks else { return nil }
        let viewModel = resolveViewModel()
        return AnyView(
            BookControlButtonsView(viewModel: viewModel) { [weak self] in
                guard let kernel = self?.kernel else { return }
                kernel.resolveProvider((any RootViewProviding).self)?.toggleContentView()
            }
        )
    }

    // MARK: - State assembly

    /// 创建并持有播放控制 ViewModel 与观察者（幂等）。
    @MainActor
    private func installState(kernel: CisumKernel) {
        guard controlViewModel == nil else { return }

        guard let scene = kernel.resolveProvider((any SceneProviding).self),
              let playback = kernel.resolveProvider((any PlaybackProviding).self) else { return }
        if Self.verbose { os_log("\(Self.t)🔧 installState") }
        let viewModel = BookControlViewModel(
            targetScene: .audiobooks,
            playbackCapability: makePlaybackCapability(from: playback),
            toastProvider: kernel.toast
        )
        let observer = BookControlObserver(scene: scene, playback: playback, viewModel: viewModel)
        controlViewModel = viewModel
        controlObserver = observer
    }

    @MainActor
    private func teardownState() {
        if Self.verbose { os_log("\(Self.t)🧹 teardownState") }
        controlObserver?.cancel()
        controlObserver = nil
        controlViewModel = nil
    }

    /// 返回当前持有的 ViewModel；若尚未安装（启动前或插件被禁用），
    /// 提供临时实例保证 View 贡献可用。
    @MainActor
    private func resolveViewModel() -> BookControlViewModel {
        if let controlViewModel {
            return controlViewModel
        }
        let viewModel = BookControlViewModel(
            targetScene: .audiobooks,
            playbackCapability: makePlaybackCapability(from: kernel?.playback),
            toastProvider: kernel?.toast
        )
        controlViewModel = viewModel
        return viewModel
    }

    /// 将内核能力收窄后注入 ViewModel；ViewModel 不持有 Kernel。
    @MainActor
    private func makePlaybackCapability(
        from playback: (any PlaybackProviding)?
    ) -> (any BookControlPlaybackCapability)? {
        guard let playback else { return nil }
        return BookControlPlaybackCapabilityAdapter(playback: playback)
    }

}
