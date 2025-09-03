import Combine
import Foundation
import MagicCore
import OSLog
import SwiftUI

@MainActor
class BookRepo: ObservableObject, SuperEvent, SuperLog {
    nonisolated static let emoji = "📖"

    private let db: BookDB
    private var disk: URL
    private let verbose: Bool
    private var monitor: Cancellable?
    private var currentSyncTask: Task<Void, Never>?
    private var isShuttingDown: Bool = false

    // MARK: - State

    enum SyncStatusBook: Equatable {
        case idle
        case syncing(items: [URL])
        case synced
        case updated
        case error(String)

        var description: String {
            switch self {
            case .idle: return "idle"
            case .syncing: return "syncing"
            case .synced: return "synced"
            case .updated: return "updated"
            case .error: return "error"
        }
        }
    }

    @Published private(set) var syncStatus: SyncStatusBook = .idle
    @Published private(set) var files: [URL] = []
    @Published private(set) var isSyncing: Bool = false

    init(disk: URL, verbose: Bool) throws {
        if verbose {
            os_log("\(Self.i)BookDB")
        }

        self.verbose = verbose
        self.db = BookDB(try BookConfig.getContainer(), reason: "BookDB")
        self.disk = disk
        self.monitor = self.makeMonitor()
    }

    func makeMonitor() -> Cancellable {
        info("Make monitor for: \(self.disk.shortPath())")

        if self.disk.isNotDirExist {
            info("Error: \(self.disk.shortPath()) not exist")
        }

        let debounceInterval = 2.0

        return self.disk.onDirChange(
            verbose: true,
            caller: self.className,
            onChange: { [weak self] items, isFirst, _ in
                guard let self = self else { return }

                @Sendable func handleChange() async {
                    guard !(await self.isShuttingDown) else { return }

                    if let lastTime = UserDefaults.standard.object(forKey: "BookLastUpdateTime") as? Date {
                        let now = Date()
                        guard now.timeIntervalSince(lastTime) >= debounceInterval else { return }
                    }
                    UserDefaults.standard.set(Date(), forKey: "BookLastUpdateTime")

                    await self.sync(items, isFirst: isFirst)
                }

                Task { await handleChange() }
            },
            onDeleted: { [weak self] _ in
                // Book 模块暂不处理删除后的额外逻辑
                guard let _ = self else { return }
            },
            onProgress: { _, _ in
                // Book 模块暂不处理下载进度
            }
        )
    }
}

// MARK: - Action

extension BookRepo {
    private func sync(_ items: [URL], isFirst: Bool) async {
        guard !isShuttingDown else { return }

        currentSyncTask?.cancel()

        // 更新状态（一次性写入，减少主线程抖动）
        self.setSyncStatus(.syncing(items: items))
        self.setIsSyncing(true)
        self.setFiles(items)

        let task = Task(priority: .utility) { [weak self] in
            guard let self = self else { return }

            let shouldContinue = await Task.detached { await !self.isShuttingDown }.value
            guard shouldContinue == true else { return }

            await self.db.sync(items, verbose: self.verbose, isFirst: isFirst)

            let shouldEmit = await Task.detached { await !self.isShuttingDown }.value
            guard shouldEmit == true else { return }

            self.setSyncStatus(isFirst ? .synced : .updated)
            self.setIsSyncing(false)
        }

        currentSyncTask = task
    }

    func getRootBooks() async -> [BookModel] {
        let urls: [URL] = await self.db.getBooks()

        return urls.map { BookModel(url: $0) }
    }

    func getRootBookURLs() async -> [URL] {
        await self.db.getBooks()
    }

    func getTotal() async -> Int {
        await self.getRootBooks().count
    }

    func delete(_ book: BookModel, verbose: Bool) async {
//        try? self.disk.deleteFile(book.url)
//        self.emit(.audioDeleted)
    }

    func download(_ book: BookModel, verbose: Bool) async throws {
//        try await self.disk.download(book.url, reason: "BookDB.download", verbose: verbose)
    }

    func find(_ url: URL) async -> URL? {
        await self.db.hasBook(url) ? url : nil
    }
}

// MARK: - Setter

extension BookRepo {
    private func setIsSyncing(_ isSyncing: Bool) {
        if self.isSyncing == isSyncing { return }

        os_log("\(self.t) setIsSyncing: \(isSyncing)")
        self.isSyncing = isSyncing
    }

    private func setFiles(_ files: [URL]) {
        if self.files == files { return }

        os_log("\(self.t) setFiles: \(files.count)")
        self.files = files
    }

    private func setSyncStatus(_ syncStatus: SyncStatusBook) {
        if self.syncStatus == syncStatus { return }

        os_log("\(self.t) setSyncStatus: \(syncStatus.description)")
        self.syncStatus = syncStatus
    }

    private func updateSyncStatus(_ status: SyncStatusBook) {
        if self.syncStatus == status { return }

        os_log("\(self.t) updateSyncStatus: \(status.description)")
        self.syncStatus = status
        self.isSyncing = (status == .syncing(items: [])) ? true : false
        if case let .syncing(items) = status {
            self.setIsSyncing(true)
            self.setFiles(items)
        } else {
            self.setIsSyncing(false)
        }
    }
}

// MARK: - Preview

#if os(macOS)
    #Preview("App - Large") {
        AppPreview()
            .frame(width: 600, height: 1000)
    }

    #Preview("App - Small") {
        AppPreview()
            .frame(width: 500, height: 800)
    }
#endif

#if os(iOS)
    #Preview("iPhone") {
        AppPreview()
    }
#endif
