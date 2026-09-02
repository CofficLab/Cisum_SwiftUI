import CisumUI
import Foundation
import OSLog
import PluginAudio

public actor AudioJobPlugin: SuperPlugin {
    public static let shared = AudioJobPlugin()
    public static let metadata = PluginMetadata(
        displayName: String(localized: "Audio Jobs", bundle: .module),
        description: String(localized: "Background tasks for audio files", bundle: .module),
        iconName: "gearshape.2",
        order: 5
    )

    public nonisolated func onRegister() {
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

    private func setupStorageLocationObserver() async {
        await MainActor.run {
            for notification in AudioPluginHost.storageLocationDidChangeNotifications {
                NotificationCenter.default.publisher(for: notification)
                    .sink { [weak self] _ in
                        Task {
                            await self?.restartFileSystemMonitor()
                        }
                    }
                    .store(in: &AudioJobNotificationObserverHolder.shared.cancellables)
            }
        }
    }

    private func restartFileSystemMonitor() async {
        let manager = AudioJobManager.shared
        let identifier = FileSystemMonitorJob(
            diskProvider: { nil },
            syncItems: { _, _ in },
            deleteItems: { _ in }
        ).identifier

        await manager.stopJob(identifier)
        try? await Task.sleep(nanoseconds: 100_000_000)
        await manager.startJob(identifier)
    }

    private func makeFileSystemMonitorJob() -> FileSystemMonitorJob {
        FileSystemMonitorJob(
            diskProvider: {
                await AudioPlugin.getAudioDisk()
            },
            syncItems: { items, isFirst in
                let disk = await AudioPlugin.getAudioDisk()
                guard let repo = await AudioPlugin.getAudioRepo() else {
                    return
                }

                let shouldFullSync = FileSystemMonitorJob.shouldPerformFullSync(isFirst: isFirst, disk: disk)
                await repo.sync(items, verbose: FileSystemMonitorJob.verbose, isFirst: shouldFullSync)
            },
            deleteItems: { urls in
                guard let repo = await AudioPlugin.getAudioRepo() else {
                    throw AudioPluginError.hostNotConfigured
                }

                try await repo.deleteAudios(urls, verbose: FileSystemMonitorJob.verbose)
            },
            notifyDeletion: {
                NotificationCenter.postFileSystemDeleted()
            }
        )
    }
}
