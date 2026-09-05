import Combine
import Foundation
import OSLog
import SwiftData
import SwiftUI
import MagicKit

/// 书籍根容器的集中状态（迁移 Phase 3）。
///
/// 持有 `BookRepo` / `ModelContainer` / 加载与错误状态，取代原
/// `BookRootView` 内的 `BookRepoState` + `initAll()` 逻辑。
/// 由 `BookPlugin` 入口持有并注入 `BookStorageObserver`。
@MainActor
final class BookRootViewModel: ObservableObject, SuperLog {
    nonisolated static let verbose = false

    @Published private(set) var repo: BookRepo?
    @Published private(set) var container: ModelContainer?
    @Published private(set) var error: Error?
    @Published private(set) var isLoading = true
    /// 存储位置变化信号，供 View 弹 toast 用。
    @Published var storageLocationDidChangeNotice = UUID()

    private let dbRootURL: @MainActor () throws -> URL
    private let bookDisk: @MainActor () -> URL?
    private var initGeneration = 0

    init(
        dbRootURL: @escaping @MainActor () throws -> URL,
        bookDisk: @escaping @MainActor () -> URL?
    ) {
        self.dbRootURL = dbRootURL
        self.bookDisk = bookDisk
    }

    /// 重新初始化容器与仓库（原 `BookRootView.initAll()`）。
    func reloadContainer() {
        initGeneration += 1
        let generation = initGeneration
        isLoading = true
        error = nil

        Task {
            do {
                let dbRootURL = try await self.dbRootURL()
                let container = try await Task.detached(priority: .userInitiated) {
                    try BookConfig.getContainer(dbRootURL: dbRootURL)
                }.value

                let disk = await self.bookDisk()
                guard let disk else {
                    await MainActor.run {
                        self.setState(nil, container: nil, error: BookPluginError.initialization(reason: String(localized: "Disk not found", bundle: .module)), generation: generation)
                    }
                    return
                }

                let db = BookDB(container, reason: "BookRootViewModel")
                let repo = try BookRepo(disk: disk, db: db)

                await MainActor.run {
                    self.setState(repo, container: container, generation: generation)
                }
            } catch {
                await MainActor.run {
                    self.setState(nil, container: nil, error: error, generation: generation)
                }
            }
        }
    }

    /// 存储位置变化：发信号并重新加载。
    func handleStorageLocationChanged() {
        storageLocationDidChangeNotice = UUID()
        reloadContainer()
    }

    private func setState(_ repo: BookRepo?, container: ModelContainer?, error: Error? = nil, generation: Int) {
        guard generation == initGeneration else { return }
        self.repo = repo
        self.container = container
        self.error = error
        self.isLoading = false
    }
}
