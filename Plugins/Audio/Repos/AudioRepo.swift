import Combine
import Foundation
import MagicCore
import OSLog
import SwiftData
import SwiftUI

@preconcurrency import Combine

// MARK: - Sync Status Enum
enum SyncStatus: Equatable {
    case idle
    case syncing(items: [URL])
    case synced
    case updated
    case error(String)
}

@MainActor
class AudioRepo: ObservableObject, SuperLog {
    nonisolated static let emoji = "🎵"
    private var db: AudioDB
    private var disk: URL
    private var monitor: Cancellable?
    private var currentSyncTask: Task<Void, Never>?
    private var isShuttingDown: Bool = false
    
    // MARK: - Published Properties for State Management
    @Published var syncStatus: SyncStatus = .idle
    @Published var files: [URL] = []
    @Published var downloadProgress: [URL: Double] = [:]
    @Published var isSyncing: Bool = false
    @Published var syncProgress: Double = 0.0

    init(disk: URL, reason: String, verbose: Bool) throws {
        if verbose {
            os_log("\(Self.i) with reason: 🐛 \(reason) 💾 with disk: \(disk.shortPath())")
        }

        let container = try AudioConfigRepo.getContainer()
        self.db = AudioDB(container, reason: reason, verbose: verbose)
        self.disk = disk
        self.monitor = self.makeMonitor()
    }

    func allAudios(reason: String) async -> [URL] {
        await self.db.allAudioURLs(reason: reason)
    }

    func changeRoot(url: URL) {
        os_log("\(self.t)🍋🍋🍋 Change disk to \(url.title)")

        Task { [weak self] in
            await self?.cleanup()
            self?.updateDisk(url)
        }
    }

    func updateDisk(_ url: URL) {
        self.disk = url
        self.monitor = self.makeMonitor()
    }

    func delete(_ audio: AudioModel, verbose: Bool) async throws {
        try self.disk.delete()
        try await db.deleteAudio(url: audio.url)
        // 更新状态而不是发送通知
        self.files.removeAll { $0 == audio.url }
        self.downloadProgress.removeValue(forKey: audio.url)
    }

    func find(_ url: URL) async -> URL? {
        await db.hasAudio(url) ? url : nil
    }

    func getFirst() async throws -> URL? {
        try await db.firstAudioURL()
    }

    func getNextOf(_ url: URL?, verbose: Bool = false) async throws -> URL? {
        try await db.getNextAudioURLOf(url, verbose: verbose)
    }

    func getPrevOf(_ url: URL?, verbose: Bool = false) async throws -> URL? {
        try await db.getPrevAudioURLOf(url, verbose: verbose)
    }

    func getTotalCount() async -> Int {
        await db.getTotalOfAudio()
    }

    func getStorageRoot() async -> URL {
        self.disk
    }

    func isLiked(_ url: URL) async -> Bool {
        await db.isLiked(url)
    }

    func like(_ url: URL?, liked: Bool) async {
        guard let url = url else { return }

        if liked {
            os_log("\(self.t)👍 Like \(url.lastPathComponent)")
            await db.like(url)
        } else {
            os_log("\(self.t)👎 Dislike \(url.lastPathComponent)")
            await db.dislike(url)
        }
    }

    func sort(_ sticky: AudioModel?, reason: String) async {
        await db.sort(sticky?.url, reason: reason)
    }

    func sort(_ url: URL?, reason: String) async {
        await db.sort(url, reason: reason)
    }

    func sortRandom(_ sticky: AudioModel?, reason: String, verbose: Bool) async throws {
        try await db.sortRandom(sticky?.url, reason: reason, verbose: verbose)
    }

    func sortRandom(_ url: URL?, reason: String, verbose: Bool) async throws {
        try await db.sortRandom(url, reason: reason, verbose: verbose)
    }

    func sync(_ items: [URL], verbose: Bool = false, isFirst: Bool) async {
        guard !isShuttingDown else { return }

        currentSyncTask?.cancel()
        
        // 更新状态而不是发送通知
        self.isSyncing = true
        self.syncStatus = .syncing(items: items)
        self.files = items

        let task = Task(priority: .utility) { [weak self] in
            guard let self = self else { return }

            let shouldContinue = await Task.detached { await !self.isShuttingDown }.value
            guard shouldContinue == true else { return }

            if isFirst {
                await db.initItems(items, verbose: verbose)
                self.updateSyncStatus(.synced)
            } else {
                await db.syncWithUpdatedItems(items, verbose: verbose)
                self.updateSyncStatus(.updated)
            }

            let shouldEmit = await Task.detached { await !self.isShuttingDown }.value
            guard shouldEmit == true else { return }
        }

        currentSyncTask = task
    }
    
    // MARK: - State Update Methods
    private func updateSyncStatus(_ status: SyncStatus) {
        self.syncStatus = status
        self.isSyncing = false
        
        switch status {
        case .synced, .updated:
            // 同步完成，可以在这里添加其他逻辑
            break
        case .error(let message):
            os_log(.error, "\(self.t)Sync error: \(message)")
        default:
            break
        }
    }

    func toggleLike(_ url: URL) async throws {
        try await db.toggleLike(url)
    }

    func makeMonitor() -> Cancellable {
        info("Make monitor for: \(self.disk.shortPath())")

        if self.disk.isNotDirExist {
            info("Error: \(self.disk.shortPath()) not exist")
        }

        let debounceInterval = 2.0

        return self.disk.onDirChange(
            verbose: false,
            caller: self.className,
            onChange: { [weak self] items, isFirst, _ in
                guard let self = self else { return }

                @Sendable func handleChange() async {
                    guard !(await self.isShuttingDown) else { return }

                    if let lastTime = UserDefaults.standard.object(forKey: "LastUpdateTime") as? Date {
                        let now = Date()
                        guard now.timeIntervalSince(lastTime) >= debounceInterval else { return }
                    }
                    UserDefaults.standard.set(Date(), forKey: "LastUpdateTime")

                    await self.sync(items, verbose: false, isFirst: isFirst)
                }

                Task {
                    await handleChange()
                }
            },
            onDeleted: { [weak self] urls in
                guard let self = self else { return }

                Task { @MainActor in
                    if urls.count > 0 {
                        try? await db.deleteAudios(urls)
                        // 更新文件列表，移除已删除的文件
                        self.files.removeAll { urls.contains($0) }
                        // 清理下载进度
                        urls.forEach { self.downloadProgress.removeValue(forKey: $0) }
                    }
                }
            },
            onProgress: { [weak self] url, progress in
                guard let self = self else { return }
                Task { @MainActor in
                    self.downloadProgress[url] = progress
                }
            })
    }

    func prepareForDeinit() {
        Task { [weak self] in
            await self?.cleanup()
        }
    }

    func cleanup() async {
        isShuttingDown = true
        currentSyncTask?.cancel()
        monitor?.cancel()
        monitor = nil
        currentSyncTask = nil
    }

    deinit {
        // 在 deinit 中不能调用 async 方法，直接清理资源
        isShuttingDown = true
        currentSyncTask?.cancel()
        // 注意：在 deinit 中不能安全地访问 monitor，因为它不是 Sendable
    }
}

// MARK: - State Management Methods

extension AudioRepo {
    /// 获取当前同步状态
    var currentSyncStatus: SyncStatus {
        syncStatus
    }
    
    /// 获取当前文件列表
    var currentFiles: [URL] {
        files
    }
    
    /// 获取指定URL的下载进度
    func getDownloadProgress(for url: URL) -> Double {
        downloadProgress[url] ?? 0.0
    }
    
    /// 清理下载进度
    func clearDownloadProgress(for url: URL) {
        downloadProgress.removeValue(forKey: url)
    }
}

#Preview("App - Large") {
    AppPreview()
        .frame(width: 600, height: 1000)
}

#Preview("App - Small") {
    AppPreview()
        .frame(width: 500, height: 800)
}

#if os(iOS)
    #Preview("iPhone") {
        AppPreview()
    }
#endif
