import KernelCore
import ProviderDocsView
import CisumUIComponents
import OSLog
import PluginBook
import ProviderPlayback
import ProviderScene
import ProviderStorage
import SwiftUI
import MagicKit

public actor BookDBPlugin: SuperPlugin, SuperLog {
    nonisolated static let verbose = true

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
    nonisolated(unsafe) private var playbackObserver: BookDBPlaybackObserver?
    /// 缓存的有声书仓库单例，供主内容区与导入流程复用，避免反复构建 SwiftData 容器。
    nonisolated(unsafe) private var cachedBookRepo: BookRepo?

    @MainActor
    public func onRegister(kernel: CisumKernel) async throws {
        if Self.verbose { os_log("\(Self.t)🔌 onRegister") }
        if let docs = kernel.docs {
            docs.addAbout(DocsEntry(id: self.id, name: Self.metadata.displayName) { BookDBPluginAboutView() })
            docs.addManual(DocsEntry(id: self.id, name: Self.metadata.displayName) { BookDBPluginManualView() })
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
        sceneBox.scene = nil
        teardownState()
    }

    @MainActor
    public func addTabView(reason: String, demoMode: Bool = false) -> (view: AnyView, label: String)? {
        guard sceneBox.scene?.currentScene == .audiobooks else { return nil }
        let label = String(localized: String.LocalizationValue(BookDBPluginInfo.titleKey), bundle: .module)
        guard let storage = kernel?.storage else {
            os_log(.error, "BookDBPlugin failed to resolve storage service")
            let view = BookDBUnavailableView(errorDescription: String(localized: "Storage service is unavailable", bundle: .module))
            return (AnyView(view), label)
        }

        let dependencies = BookDBViewDependencies(
            dbRoot: storage.databaseRoot,
            bookDisk: bookDiskProvider(),
            isDesktop: ConfigShim.isDesktop,
            isNotDesktop: ConfigShim.isNotDesktop,
            bookRepo: bookRepoProvider
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
        let settingList = BookListViewModel(bookRepo: bookRepoProvider)
        return PluginSettingNavigationItem(
            id: "bookdb",
            title: String(localized: String.LocalizationValue(BookDBPluginInfo.titleKey), bundle: .module),
            description: Self.metadata.description,
            iconName: Self.metadata.iconName,
            order: Self.metadata.order,
            destination: AnyView(
                BookDBSettingView()
                    .environmentObject(settingList)
                    .environment(\.bookDBDependencies, settingDependencies)
            )
        )
    }

    /// 设置页依赖：仓库路径 / 仓库均由本插件自持（不依赖 `BookPlugin`）。
    @MainActor
    private var settingDependencies: BookDBDependencies {
        BookDBDependencies(
            bookRepo: bookRepoProvider,
            bookDisk: bookDiskProvider
        )
    }

    // MARK: - State assembly

    // MARK: - 仓库路径自持（不依赖 BookPlugin actor）

    /// 有声书仓库磁盘目录：`storageRoot` + `BookPluginInfo.dirName`。
    ///
    /// 由本插件直接从内核存储服务解析，不再经由 `BookPlugin` 的静态入口，
    /// 因此 `BookPlugin` 的启用状态不影响仓库可用性。
    @MainActor
    private static func makeBookDisk(from storage: any StorageProviding) -> URL? {
        guard let root = storage.storageRoot else { return nil }
        return try? root
            .appendingPathComponent(BookPluginInfo.dirName, isDirectory: true)
            .ensureDirectory()
    }

    /// 构建有声书仓库：磁盘目录 + SwiftData 容器 + `BookRepo`。
    ///
    /// dbRoot（`storage.databaseRoot`）与磁盘目录在 MainActor 上解析，
    /// SwiftData 容器创建放到 utility 任务，避免阻塞 UI（对齐 `BookPlugin` 既有策略）。
    @MainActor
    private static func makeBookRepo(from storage: any StorageProviding) async -> BookRepo? {
        guard let disk = Self.makeBookDisk(from: storage) else { return nil }
        let dbRoot = storage.databaseRoot
        let container = await Task.detached(priority: .utility) {
            try? BookConfig.getContainer(dbRootURL: dbRoot)
        }.value
        guard let container else { return nil }
        return try? BookRepo(disk: disk, db: BookDB(container, reason: "BookDBPlugin"))
    }

    /// 有声书仓库磁盘目录解析器。
    @MainActor
    private var bookDiskProvider: @MainActor @Sendable () -> URL? {
        { @MainActor [weak self] in
            guard let storage = self?.kernel?.storage else { return nil }
            return Self.makeBookDisk(from: storage)
        }
    }

    /// 有声书仓库解析器：首次解析成功后缓存单例，后续直接复用。
    @MainActor
    private var bookRepoProvider: @MainActor @Sendable () async -> BookRepo? {
        { @MainActor [weak self] in
            guard let self else { return nil }
            if let cached = self.cachedBookRepo {
                return cached
            }
            guard let storage = self.kernel?.storage else { return nil }
            let repo = await Self.makeBookRepo(from: storage)
            if let repo {
                self.cachedBookRepo = repo
            }
            return repo
        }
    }

    @MainActor
    private func installState(kernel: CisumKernel) {
        guard gridViewModel == nil else { return }

        guard let scene = kernel.resolveProvider((any SceneProviding).self) else { return }
        sceneBox.scene = scene
        if Self.verbose { os_log("\(Self.t)🔧 installState") }

        let viewModel = BookGridViewModel(
            playbackCapability: makePlaybackCapability(from: kernel.playback)
        )
        let observer = BookDatabaseObserver(viewModel: viewModel)
        let playbackObserver = BookDBPlaybackObserver(playback: kernel.playback, viewModel: viewModel)
        gridViewModel = viewModel
        databaseObserver = observer
        self.playbackObserver = playbackObserver
    }

    @MainActor
    private func teardownState() {
        if Self.verbose { os_log("\(Self.t)🧹 teardownState") }
        databaseObserver?.cancel()
        databaseObserver = nil
        playbackObserver?.cancel()
        playbackObserver = nil
        gridViewModel = nil
        cachedBookRepo = nil
    }

    @MainActor
    private func resolveViewModel() -> BookGridViewModel {
        if let gridViewModel {
            return gridViewModel
        }
        let viewModel = BookGridViewModel(
            playbackCapability: makePlaybackCapability(from: kernel?.playback)
        )
        gridViewModel = viewModel
        return viewModel
    }

    /// 将内核播放 Provider 收窄后注入 ViewModel。
    @MainActor
    private func makePlaybackCapability(
        from playback: (any PlaybackProviding)?
    ) -> (any BookDBPlaybackCapability)? {
        guard let playback else { return nil }
        return BookDBPlaybackCapabilityAdapter(playback: playback)
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
