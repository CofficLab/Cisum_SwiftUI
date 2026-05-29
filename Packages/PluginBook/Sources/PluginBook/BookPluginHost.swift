import Foundation

public enum BookPluginHost {
    public typealias DBRootProvider = @MainActor () throws -> URL
    public typealias StorageRootProvider = @MainActor () -> URL?

    nonisolated(unsafe) private static var dbRootProvider: DBRootProvider?
    nonisolated(unsafe) private static var storageRootProvider: StorageRootProvider?
    nonisolated(unsafe) private static var storageLocationDidChangeNotificationsValue: [Notification.Name] = []

    @MainActor
    public static func configure(
        dbRoot: @escaping DBRootProvider,
        storageRoot: @escaping StorageRootProvider,
        storageLocationDidChangeNotifications: [Notification.Name]
    ) {
        dbRootProvider = dbRoot
        storageRootProvider = storageRoot
        storageLocationDidChangeNotificationsValue = storageLocationDidChangeNotifications
    }

    @MainActor
    public static func getDBRootDir() throws -> URL {
        guard let dbRootProvider else {
            throw BookPluginError.configurationMissing
        }
        return try dbRootProvider()
    }

    @MainActor
    public static func getStorageRoot() -> URL? {
        storageRootProvider?()
    }

    @MainActor
    public static var storageLocationDidChangeNotifications: [Notification.Name] {
        storageLocationDidChangeNotificationsValue
    }
}
