import KernelCore
import ProviderDocsView
import CisumUIComponents
import Foundation
import OSLog
import ProviderStorage
import SwiftUI
import MagicKit

public actor BookPlugin: SuperPlugin, SuperLog {
    nonisolated static let verbose = false

    public static let shared = BookPlugin()
    public static let metadata = PluginMetadata(
        displayName: BookPluginInfo.title,
        description: BookPluginInfo.description,
        iconName: BookPluginInfo.iconName,
        order: 1,
        category: .library,
    )

    nonisolated(unsafe) private var rootViewModel: BookRootViewModel?
    nonisolated(unsafe) private var rootObserver: BookStorageObserver?

    @MainActor
    public func onRegister(kernel: CisumKernel) async throws {
        if Self.verbose { os_log("\(Self.t)🔌 onRegister") }
        if let docs = kernel.docs {
            docs.addAbout(DocsEntry(id: self.id, name: Self.metadata.displayName) { BookPluginAboutView() })
            docs.addManual(DocsEntry(id: self.id, name: Self.metadata.displayName) { BookPluginManualView() })
        }
    }

    public static let keyOfCurrentBookURL = BookPluginInfo.keyOfCurrentBookURL
    public static let keyOfCurrentBookTime = BookPluginInfo.keyOfCurrentBookTime
    public static let dirName = BookPluginInfo.dirName
    public static let supportedExtensions = BookPluginInfo.supportedExtensions

    /// OnReady 阶段（Storage 服务已注册）将 `BookPluginHost` 桥接到内核
    /// `StorageProviding`，并安装根 ViewModel + Observer。
    @MainActor
    public func onReady(kernel: CisumKernel) async throws {
        if Self.verbose { os_log("\(Self.t)🟢 onReady") }
        guard let storage = kernel.storage else {
            os_log(.error, "\(Self.t)❌ onReady: storage 服务不可用")
            return
        }
        BookPluginHost.configure(
            dbRoot: { storage.databaseRoot },
            storageRoot: { storage.storageRoot },
            storageLocationDidChangeNotifications: [.cisumStorageLocationDidChange, .cisumStorageLocationDidReset]
        )
        installRootState(storage: storage)
    }

    @MainActor
    public func onEnable(kernel: CisumKernel) async throws {
        if Self.verbose { os_log("\(Self.t)✅ onEnable") }
        if let storage = kernel.storage {
            installRootState(storage: storage)
        }
    }

    @MainActor
    public func onDisable(kernel: CisumKernel) async throws {
        if Self.verbose { os_log("\(Self.t)⏹️ onDisable") }
        teardownRootState()
    }

    @MainActor
    public func onShutdown(kernel: CisumKernel) async throws {
        if Self.verbose { os_log("\(Self.t)🛑 onShutdown") }
        teardownRootState()
    }

    @MainActor
    public func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        let viewModel = resolveRootViewModel()
        if Self.verbose { os_log("\(Self.t)📺 addRootView") }
        return AnyView(BookRootView(viewModel: viewModel, content: content))
    }

    @MainActor
    public static func getBookDisk() -> URL? {
        guard let storageRoot = BookPluginHost.getStorageRoot() else {
            return nil
        }

        let disk = storageRoot.appendingPathComponent(Self.dirName, isDirectory: true)
        return try? disk.ensureDirectory()
    }

    /// 后台构造书籍仓库。dbRoot 与 disk 的解析仍在主线程完成，
    /// SwiftData 容器创建及仓库初始化放到 utility 任务，避免阻塞 UI。
    public static func getBookRepoAsync() async -> BookRepo? {
        if Self.verbose { os_log("\(Self.t)📚 getBookRepoAsync") }
        let dbRoot = await MainActor.run { try? BookPluginHost.getDBRootDir() }
        guard let dbRoot else { return nil }
        let disk = await MainActor.run { Self.getBookDisk() }
        guard let disk else { return nil }

        let container = await Task.detached(priority: .utility) {
            try? BookConfig.getContainer(dbRootURL: dbRoot)
        }.value
        guard let container else { return nil }

        return await MainActor.run {
            try? BookRepo(disk: disk, db: BookDB(container, reason: "BookPlugin.background"))
        }
    }

    // MARK: - State assembly

    @MainActor
    private func installRootState(storage: any StorageProviding) {
        guard rootViewModel == nil else { return }
        if Self.verbose { os_log("\(Self.t)🔧 installRootState") }
        let viewModel = BookRootViewModel(
            dbRootURL: { try BookPluginHost.getDBRootDir() },
            bookDisk: { Self.getBookDisk() }
        )
        let observer = BookStorageObserver(storage: storage, viewModel: viewModel)
        rootViewModel = viewModel
        rootObserver = observer
    }

    @MainActor
    private func teardownRootState() {
        if Self.verbose { os_log("\(Self.t)🧹 teardownRootState") }
        rootObserver?.cancel()
        rootObserver = nil
        rootViewModel = nil
    }

    @MainActor
    private func resolveRootViewModel() -> BookRootViewModel {
        if let rootViewModel {
            return rootViewModel
        }
        let viewModel = BookRootViewModel(
            dbRootURL: { try BookPluginHost.getDBRootDir() },
            bookDisk: { Self.getBookDisk() }
        )
        rootViewModel = viewModel
        return viewModel
    }
}
