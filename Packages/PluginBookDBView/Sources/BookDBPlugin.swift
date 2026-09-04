import KernelCore
import ProviderDocsView
import CisumUIComponents
import OSLog
import PluginBook
import ProviderPlayback
import ProviderScene
import SwiftUI

public actor BookDBPlugin: SuperPlugin {
    public static let shared = BookDBPlugin()
    public static let metadata = PluginMetadata(
        displayName: String(localized: String.LocalizationValue(BookDBPluginInfo.titleKey), bundle: .module),
        description: String(localized: String.LocalizationValue(BookDBPluginInfo.descriptionKey), bundle: .module),
        iconName: BookDBPluginInfo.iconName,
        order: 12,
        policy: .alwaysOn,
        category: .library,
    )

    nonisolated(unsafe) private let sceneBox = SceneBox()
    nonisolated(unsafe) private weak var kernel: CisumKernel?
    nonisolated(unsafe) private var gridViewModel: BookGridViewModel?
    nonisolated(unsafe) private var databaseObserver: BookDatabaseObserver?

    @MainActor
    public func onRegister(kernel: CisumKernel) async throws {
        if let docs = kernel.docs {
            docs.addAbout(DocsEntry(id: self.id, name: Self.metadata.displayName) { BookDBPluginAboutView() })
            docs.addManual(DocsEntry(id: self.id, name: Self.metadata.displayName) { BookDBPluginManualView() })
        }
    }

    @MainActor
    public func onBoot(kernel: CisumKernel) async throws {
        self.kernel = kernel
        guard let scene = kernel.resolveProvider((any SceneProviding).self) else {
            throw CisumKernelError.serviceNotAvailable(service: "SceneProviding")
        }
        sceneBox.scene = scene
        installState()
    }

    @MainActor
    public func onEnable(kernel: CisumKernel) async throws {
        self.kernel = kernel
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
    public func addTabView(reason: String, demoMode: Bool = false) -> (view: AnyView, label: String)? {
        guard sceneBox.scene?.currentScene == .audiobooks else { return nil }
        let label = String(localized: String.LocalizationValue(BookDBPluginInfo.titleKey), bundle: .module)
        let dbRoot: URL

        do {
            dbRoot = try BookPluginHost.getDBRootDir()
        } catch {
            os_log(.error, "BookDBPlugin failed to get database root: \(error.localizedDescription)")
            let view = BookDBUnavailableView(errorDescription: error.localizedDescription)
            return (AnyView(view), label)
        }

        let dependencies = BookDBViewDependencies(
            dbRoot: dbRoot,
            bookDisk: BookPlugin.getBookDisk(),
            isDesktop: ConfigShim.isDesktop,
            isNotDesktop: ConfigShim.isNotDesktop
        )
        let viewModel = resolveViewModel()
        let view = BookDBView()
            .environmentObject(viewModel)
            .bookDBViewDependencies(dependencies)
        return (AnyView(view), label)
    }

    /// 设置窗口入口：展示有声书仓库书籍列表。
    @MainActor
    public func addSettingNavigationItem() -> PluginSettingNavigationItem? {
        // 设置页使用独立的 BookListViewModel，避免与主窗口内容区（BookGrid）
        // 共享同一实例——否则设置页 onAppear 触发重载时，共享状态变化会传播
        // 到主窗口内容区，导致其闪动。
        let settingList = BookListViewModel(bookRepo: { await BookPlugin.getBookRepoAsync() })
        return PluginSettingNavigationItem(
            id: "bookdb",
            title: String(localized: String.LocalizationValue(BookDBPluginInfo.titleKey), bundle: .module),
            description: Self.metadata.description,
            iconName: Self.metadata.iconName,
            order: Self.metadata.order,
            destination: AnyView(
                BookDBSettingView()
                    .environmentObject(settingList)
            )
        )
    }

    // MARK: - State assembly

    /// 内核播放服务解析器：书籍/章节点击经 `kernel.playback`（`PlaybackProviding`）播放，
    /// 将其设置为当前文件，而不是直接调用播放引擎。
    @MainActor
    private var playbackProvider: @MainActor () -> (any PlaybackProviding)? {
        { @MainActor [weak self] in
            self?.kernel?.playback
        }
    }

    @MainActor
    private func installState() {
        guard gridViewModel == nil else { return }
        let viewModel = BookGridViewModel(playbackProvider: playbackProvider)
        let observer = BookDatabaseObserver(viewModel: viewModel)
        gridViewModel = viewModel
        databaseObserver = observer
    }

    @MainActor
    private func teardownState() {
        databaseObserver?.cancel()
        databaseObserver = nil
        gridViewModel = nil
    }

    @MainActor
    private func resolveViewModel() -> BookGridViewModel {
        if let gridViewModel {
            return gridViewModel
        }
        let viewModel = BookGridViewModel(playbackProvider: playbackProvider)
        gridViewModel = viewModel
        return viewModel
    }

    private final class SceneBox {
        weak var scene: (any SceneProviding)?
    }
}

private struct BookDBUnavailableView: View {
    let errorDescription: String

    var body: some View {
        AppEmptyState(
            icon: "exclamationmark.triangle",
            title: String(localized: "Book repository is unavailable", bundle: .module),
            description: String(localized: "Database location could not be opened: \(errorDescription)", bundle: .module)
        )
    }
}

private enum ConfigShim {
    static var isDesktop: Bool {
        #if os(macOS)
            true
        #else
            false
        #endif
    }

    static var isNotDesktop: Bool { !isDesktop }
}
