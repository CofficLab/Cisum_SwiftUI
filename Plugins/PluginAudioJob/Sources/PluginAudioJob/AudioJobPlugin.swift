import CisumUI
import Combine
import Foundation
import OSLog
import PluginAudio

@MainActor
private final class AudioJobNotificationObserverHolder {
    static let shared = AudioJobNotificationObserverHolder()
    var cancellables = Set<AnyCancellable>()
    private init() {}
}

public actor AudioJobPlugin: SuperPlugin {
    public static let shared = AudioJobPlugin()
    public static var shouldRegister: Bool { true }
    public static var order: Int { 5 }

    public nonisolated var description: String {
        String(localized: "Background tasks for audio files", table: "Audio-Job", bundle: .module)
    }

    public nonisolated var iconName: String { "gearshape.2" }

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
                guard let repo = await AudioPlugin.getAudioRepo() else {
                    return
                }

                await repo.sync(items, verbose: FileSystemMonitorJob.verbose, isFirst: isFirst)
            },
            deleteItems: { urls in
                guard let repo = await AudioPlugin.getAudioRepo() else {
                    return
                }

                try? await repo.deleteAudios(urls, verbose: FileSystemMonitorJob.verbose)
            },
            notifyDeletion: {
                NotificationCenter.postFileSystemDeleted()
            }
        )
    }
}
