import Foundation
import AudioLikeCore

public enum AudioPluginHost {
    public typealias DatabaseURLProvider = @MainActor (_ name: String) throws -> URL
    public typealias StorageRootProvider = @MainActor () -> URL?
    public typealias HasStorageLocationProvider = @MainActor () -> Bool

    nonisolated(unsafe) private static var databaseURLProvider: DatabaseURLProvider?
    nonisolated(unsafe) private static var storageRootProvider: StorageRootProvider?
    nonisolated(unsafe) private static var hasStorageLocationProvider: HasStorageLocationProvider?
    nonisolated(unsafe) private static var storageLocationDidChangeNotificationsValue: [Notification.Name] = []

    @MainActor
    public static func configure(
        databaseURL: @escaping DatabaseURLProvider,
        storageRoot: @escaping StorageRootProvider,
        hasStorageLocation: @escaping HasStorageLocationProvider,
        storageLocationDidChangeNotifications: [Notification.Name]
    ) {
        databaseURLProvider = databaseURL
        storageRootProvider = storageRoot
        hasStorageLocationProvider = hasStorageLocation
        storageLocationDidChangeNotificationsValue = storageLocationDidChangeNotifications
    }

    @MainActor
    public static func createDatabaseFile(name: String) throws -> URL {
        guard let databaseURLProvider else {
            throw AudioPluginError.hostNotConfigured
        }
        return try databaseURLProvider(name)
    }

    @MainActor
    public static func getStorageRoot() -> URL? {
        storageRootProvider?()
    }

    @MainActor
    public static func hasStorageLocation() -> Bool {
        hasStorageLocationProvider?() ?? false
    }

    /// 返回音频库目录。功能插件通过这个中立宿主访问外部存储，
    /// 不需要依赖 `PluginAudio` 生命周期插件。
    @MainActor
    public static func getAudioDisk() -> URL? {
        guard let storageRoot = getStorageRoot() else { return nil }
        let disk = storageRoot.appendingPathComponent(
            AudioPluginInfo.effectiveDBDirName,
            isDirectory: true
        )
        return try? disk.ensureDirectory()
    }

    /// 诊断音频仓库路径解析链路。
    @MainActor
    public static func audioStorageDiagnostics() -> AudioStorageDiagnostics {
        let storageLocationRaw = UserDefaults.standard.string(forKey: "StorageLocation")
        let isICloudAvailable = FileManager.default.ubiquityIdentityToken != nil
        let cloudContainer = FileManager.default.url(forUbiquityContainerIdentifier: nil)
        let cloudDocuments = cloudContainer?.appendingPathComponent("Documents")
        let localDocuments = try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let storageRoot = getStorageRoot()
        let disk = getAudioDisk()

        return AudioStorageDiagnostics(
            storageLocationRaw: storageLocationRaw,
            isICloudAvailable: isICloudAvailable,
            hasUsableStorageLocation: hasStorageLocation(),
            cloudContainer: cloudContainer?.path,
            cloudDocuments: cloudDocuments?.path,
            localDocuments: localDocuments?.path,
            storageRoot: storageRoot?.path,
            audioDisk: disk?.path,
            dbDirName: AudioPluginInfo.effectiveDBDirName
        )
    }

    @MainActor
    public static func getAudioRepo() -> AudioRepo? {
        guard let configuration = audioRepoConfiguration() else { return nil }
        return try? AudioRepo(
            disk: configuration.disk,
            databaseURL: configuration.databaseURL,
            reason: "AudioPluginHost"
        )
    }

    public static func getAudioRepoAsync() async -> AudioRepo? {
        let configuration = await MainActor.run { audioRepoConfiguration() }
        guard let configuration else { return nil }

        let container = await Task.detached(priority: .utility) {
            try? AudioConfigRepo.getContainer(databaseURL: configuration.databaseURL)
        }.value
        guard let container else { return nil }

        return await MainActor.run {
            try? AudioRepo(
                container: container,
                disk: configuration.disk,
                reason: "AudioPluginHost.background"
            )
        }
    }

    @MainActor
    private static func audioRepoConfiguration() -> AudioRepoConfiguration? {
        guard let disk = getAudioDisk() else { return nil }
        guard let audioLikeDatabaseURL = try? createDatabaseFile(name: "audio_like") else {
            return nil
        }
        AudioLikeRepositoryConfiguration.configure(databaseURL: audioLikeDatabaseURL)

        guard let databaseURL = try? createDatabaseFile(name: "audio") else {
            return nil
        }
        return AudioRepoConfiguration(disk: disk, databaseURL: databaseURL)
    }

    private struct AudioRepoConfiguration: Sendable {
        let disk: URL
        let databaseURL: URL
    }

    @MainActor
    public static var storageLocationDidChangeNotifications: [Notification.Name] {
        storageLocationDidChangeNotificationsValue
    }
}
