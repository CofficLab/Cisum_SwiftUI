@preconcurrency import Combine
import Foundation
import MagicKit
import OSLog

public final class FileSystemMonitorJob: AudioJob, @unchecked Sendable {
    public typealias DiskProvider = @Sendable () async -> URL?
    public typealias SyncItems = @Sendable (_ items: [URL], _ isFirst: Bool) async -> Void
    public typealias DeleteItems = @Sendable (_ urls: [URL]) async -> Void
    public typealias DeletionNotifier = @Sendable () async -> Void

    public static let verbose = false

    public nonisolated let identifier = "com.cisum.audio.job.filesystem-monitor"
    public nonisolated let name = String(localized: "File System Monitor", table: "Audio-Job", bundle: .module)
    public nonisolated let description = String(localized: "Monitor audio file system changes and sync to database", table: "Audio-Job", bundle: .module)

    private var monitor: Cancellable?
    private let state = State()
    private let diskProvider: DiskProvider
    private let syncItems: SyncItems
    private let deleteItems: DeleteItems
    private let notifyDeletion: DeletionNotifier

    public init(
        diskProvider: @escaping DiskProvider,
        syncItems: @escaping SyncItems,
        deleteItems: @escaping DeleteItems,
        notifyDeletion: @escaping DeletionNotifier = {}
    ) {
        self.diskProvider = diskProvider
        self.syncItems = syncItems
        self.deleteItems = deleteItems
        self.notifyDeletion = notifyDeletion
    }

    public func execute() async throws {
        guard let disk = await diskProvider() else {
            if Self.verbose {
                os_log("❌ Unable to resolve audio disk path")
            }
            return
        }

        if Self.verbose {
            os_log("👀 Start monitoring audio disk: \(disk.path)")
        }

        await state.setRunning(true)

        await withCheckedContinuation { continuation in
            monitor = disk.onDirChange(
                verbose: Self.verbose,
                caller: String(describing: Self.self) + ".execute",
                onChange: { @Sendable [weak self] items, isFirst, _ in
                    guard let self else { return }

                    Task {
                        guard await self.state.shouldSync() else {
                            return
                        }

                        if Self.verbose {
                            os_log("📂 Audio file system changed: \(items.count) item(s), first: \(isFirst)")
                        }

                        await self.syncItems(items, isFirst)
                    }
                },
                onDeleted: { @Sendable [weak self] urls in
                    guard let self else { return }

                    Task {
                        if Self.verbose {
                            os_log("🗑️ Audio files deleted: \(urls.count)")
                        }

                        await self.deleteItems(urls)
                        await self.notifyDeletion()

                        if Self.verbose {
                            os_log("✅ Audio deletion sync completed")
                        }
                    }
                },
                onProgress: { _, _ in }
            )

            continuation.resume()
        }

        while await state.getRunning() {
            try Task.checkCancellation()
            try await Task.sleep(nanoseconds: 1_000_000_000)
        }

        if Self.verbose {
            os_log("✅ Audio file system monitor finished")
        }
    }

    public func cancel() {
        Task { @Sendable [weak self] in
            guard let self else { return }
            await self.state.setRunning(false)
        }

        monitor?.cancel()
        monitor = nil

        if Self.verbose {
            os_log("⏹️ Audio file system monitor stopped")
        }
    }

    private actor State {
        var isRunning = false
        var lastSyncTime: Date?

        func setRunning(_ running: Bool) {
            isRunning = running
        }

        func getRunning() -> Bool {
            isRunning
        }

        func shouldSync() -> Bool {
            guard let lastSyncTime else {
                self.lastSyncTime = Date()
                return true
            }

            let now = Date()
            let elapsed = now.timeIntervalSince(lastSyncTime)

            guard elapsed >= 2.0 else {
                return false
            }

            self.lastSyncTime = now
            return true
        }
    }
}
