import Foundation

public enum StoragePluginHost {
    public typealias GetStorageLocation = @MainActor @Sendable () -> PluginStorageLocation?
    public typealias UpdateStorageLocation = @MainActor @Sendable (PluginStorageLocation?) -> Void
    public typealias GetStorageRoot = @MainActor @Sendable () -> URL?
    public typealias GetStorageRootForLocation = @MainActor @Sendable (PluginStorageLocation) -> URL?
    public typealias PostStorageLocationUpdated = @MainActor @Sendable () -> Void

    private nonisolated(unsafe) static var getStorageLocationHandler: GetStorageLocation = { nil }
    private nonisolated(unsafe) static var updateStorageLocationHandler: UpdateStorageLocation = { _ in }
    private nonisolated(unsafe) static var getStorageRootHandler: GetStorageRoot = { nil }
    private nonisolated(unsafe) static var getStorageRootForLocationHandler: GetStorageRootForLocation = { _ in nil }
    private nonisolated(unsafe) static var postStorageLocationUpdatedHandler: PostStorageLocationUpdated = {}
    private nonisolated(unsafe) static var isDesktopValue = true

    public static func configure(
        getStorageLocation: @escaping GetStorageLocation,
        updateStorageLocation: @escaping UpdateStorageLocation,
        getStorageRoot: @escaping GetStorageRoot,
        getStorageRootForLocation: @escaping GetStorageRootForLocation,
        postStorageLocationUpdated: @escaping PostStorageLocationUpdated,
        isDesktop: Bool
    ) {
        getStorageLocationHandler = getStorageLocation
        updateStorageLocationHandler = updateStorageLocation
        getStorageRootHandler = getStorageRoot
        getStorageRootForLocationHandler = getStorageRootForLocation
        postStorageLocationUpdatedHandler = postStorageLocationUpdated
        isDesktopValue = isDesktop
    }

    @MainActor
    public static var dependencies: StorageDependencies {
        StorageDependencies(
            getStorageLocation: getStorageLocationHandler,
            updateStorageLocation: updateStorageLocationHandler,
            getStorageRoot: getStorageRootHandler,
            getStorageRootForLocation: getStorageRootForLocationHandler,
            postStorageLocationUpdated: postStorageLocationUpdatedHandler,
            isDesktop: isDesktopValue
        )
    }
}
