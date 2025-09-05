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
    private let coverRepo: BookCoverRepo

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
        self.coverRepo = BookCoverRepo()
        self.monitor = try self.makeMonitor()
    }

    func makeMonitor() throws -> Cancellable {
        os_log("\(self.t)📸 Make monitor for: \(self.disk.shortPath())")

        if self.disk.isNotDirExist {
            os_log(.error, "\(self.t)Error: \(self.disk.absoluteString) not exist")
            throw BookPluginError.DiskNotFound
        }

        let debounceInterval = 2.5

        return self.disk.onDirChange(
            verbose: true,
            caller: self.className,
            onChange: { items, isFirst, _ in
                os_log("\(self.t) Disk changed, with items \(items.count)")
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
        await self.db.sync(items, verbose: self.verbose, isFirst: isFirst)
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
    
    /// 获取书籍封面图
    /// - Parameters:
    ///   - url: 书籍URL
    ///   - thumbnailSize: 缩略图尺寸
    /// - Returns: 封面图，如果未找到则返回nil
    func getCover(for url: URL, thumbnailSize: CGSize) async -> Image? {
        return await coverRepo.getCover(for: url, thumbnailSize: thumbnailSize)
    }
}

// MARK: - Setter

extension BookRepo {
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
