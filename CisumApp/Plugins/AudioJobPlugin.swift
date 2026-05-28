import Combine
import Foundation
import MagicKit
import OSLog
import PluginAudioJob
import SwiftUI
import PluginAudio

@MainActor
private final class AudioJobNotificationObserverHolder {
    static let shared = AudioJobNotificationObserverHolder()
    var cancellables = Set<AnyCancellable>()
    private init() {}
}

actor AudioJobPlugin: SuperPlugin, SuperLog {
    static let shared = AudioJobPlugin()
    static let emoji = "⚙️"
    static let verbose = false
    static var shouldRegister: Bool { true }
    static var order: Int { 5 }

    nonisolated var description: String { String(localized: "Background tasks for audio files", table: "Audio-Job") }
    let iconName = "gearshape.2"

    nonisolated func onRegister() {
        Task {
            await registerJobs()
            await setupStorageLocationObserver()
        }
    }

    private func registerJobs() async {
        let manager = AudioJobManager.shared
        let fsMonitorJob = makeFileSystemMonitorJob()

        await manager.register(fsMonitorJob)
        await manager.startJob(fsMonitorJob.identifier)
    }

    func startJob(identifier: String) async {
        await AudioJobManager.shared.startJob(identifier)
    }

    private func setupStorageLocationObserver() async {
        await MainActor.run {
            NotificationCenter.default.publisher(for: .storageLocationDidReset)
                .sink { [weak self] _ in
                    Task {
                        await self?.restartFileSystemMonitor()
                    }
                }
                .store(in: &AudioJobNotificationObserverHolder.shared.cancellables)

            NotificationCenter.default.publisher(for: .storageLocationUpdated)
                .sink { [weak self] _ in
                    Task {
                        await self?.restartFileSystemMonitor()
                    }
                }
                .store(in: &AudioJobNotificationObserverHolder.shared.cancellables)
        }
    }

    private func restartFileSystemMonitor() async {
        let manager = AudioJobManager.shared
        let identifier = FileSystemMonitorJob(
            diskProvider: { nil },
            syncItems: { _, _ in },
            deleteItems: { _ in }
        ).identifier

        if Self.verbose {
            os_log("\(Self.t)🔄 存储位置变化，重启文件系统监控")
        }

        await manager.stopJob(identifier)
        try? await Task.sleep(nanoseconds: 100_000_000)
        await manager.startJob(identifier)

        if Self.verbose {
            os_log("\(Self.t)✅ 文件系统监控已重启")
        }
    }

    private func makeFileSystemMonitorJob() -> FileSystemMonitorJob {
        FileSystemMonitorJob(
            diskProvider: {
                await AudioPlugin.getAudioDisk()
            },
            syncItems: { items, isFirst in
                guard let repo = await AudioPlugin.getAudioRepo() else {
                    if Self.verbose {
                        os_log("\(Self.t)❌ 无法获取 AudioRepo 实例")
                    }
                    return
                }

                await repo.sync(items, verbose: FileSystemMonitorJob.verbose, isFirst: isFirst)
            },
            deleteItems: { urls in
                guard let repo = await AudioPlugin.getAudioRepo() else {
                    if Self.verbose {
                        os_log("\(Self.t)❌ 无法获取 AudioRepo 实例")
                    }
                    return
                }

                await repo.deleteAudios(urls, verbose: FileSystemMonitorJob.verbose)
            },
            notifyDeletion: {
                NotificationCenter.postFileSystemDeleted()
            }
        )
    }
}
