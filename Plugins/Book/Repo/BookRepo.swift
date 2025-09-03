import Combine
import Foundation
import MagicCore
import OSLog
import SwiftUI

class BookRepo: ObservableObject, SuperEvent, SuperLog {
    nonisolated static let emoji = "📖"

    private let db: BookDB
    private var disk: URL
    private let verbose: Bool
    private var monitor: Cancellable?
    private var currentSyncTask: Task<Void, Never>?
    private var isShuttingDown: Bool = false
    private var syncStatus: SyncStatusBook = .idle
    private var isSyncing: Bool = false

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

    init(disk: URL, verbose: Bool, db: BookDB) throws {
        if verbose {
            os_log("\(Self.i)BookDB")
        }

        self.verbose = verbose
        self.db = db
        self.disk = disk
        self.monitor = self.makeMonitor()
    }

    func makeMonitor() -> Cancellable {
        info("Make monitor for: \(self.disk.shortPath())")

        if self.disk.isNotDirExist {
            info("Error: \(self.disk.shortPath()) not exist")
        }

        let debounceInterval = 2.5

        return self.disk.onDirChange(
            verbose: true,
            caller: self.className,
            onChange: { items, isFirst, _ in

                if let lastTime = UserDefaults.standard.object(forKey: "BookLastUpdateTime") as? Date {
                    let now = Date()
                    guard now.timeIntervalSince(lastTime) >= debounceInterval else { return }
                }
                UserDefaults.standard.set(Date(), forKey: "BookLastUpdateTime")

                await self.sync(items, isFirst: isFirst)

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

        // 更新状态（一次性写入，减少主线程抖动）
        self.setSyncStatus(.syncing(items: items))
        self.setIsSyncing(true)


        await self.db.sync(items, verbose: self.verbose, isFirst: isFirst)



        // 同步完成后立即更新状态

        self.setSyncStatus(.updated)
        self.setIsSyncing(false)
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
