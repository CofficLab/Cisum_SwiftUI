import Foundation

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
    static func createDatabaseFile(name: String) throws -> URL {
        guard let databaseURLProvider else {
            throw AudioPluginError.hostNotConfigured
        }
        return try databaseURLProvider(name)
    }

    @MainActor
    static func getStorageRoot() -> URL? {
        storageRootProvider?()
    }

    @MainActor
    static func hasStorageLocation() -> Bool {
        hasStorageLocationProvider?() ?? false
    }

    @MainActor
    public static var storageLocationDidChangeNotifications: [Notification.Name] {
        storageLocationDidChangeNotificationsValue
    }
}
