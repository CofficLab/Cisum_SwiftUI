import SwiftUI

public struct StorageDependencies: @unchecked Sendable {
    public var getStorageLocation: () -> PluginStorageLocation?
    public var updateStorageLocation: (PluginStorageLocation?) -> Void
    public var getStorageRoot: () -> URL?
    public var getStorageRootForLocation: (PluginStorageLocation) -> URL?
    public var postStorageLocationUpdated: () -> Void
    public var isDesktop: Bool

    public init(
        getStorageLocation: @escaping () -> PluginStorageLocation?,
        updateStorageLocation: @escaping (PluginStorageLocation?) -> Void,
        getStorageRoot: @escaping () -> URL?,
        getStorageRootForLocation: @escaping (PluginStorageLocation) -> URL?,
        postStorageLocationUpdated: @escaping () -> Void,
        isDesktop: Bool
    ) {
        self.getStorageLocation = getStorageLocation
        self.updateStorageLocation = updateStorageLocation
        self.getStorageRoot = getStorageRoot
        self.getStorageRootForLocation = getStorageRootForLocation
        self.postStorageLocationUpdated = postStorageLocationUpdated
        self.isDesktop = isDesktop
    }

    static let preview = StorageDependencies(
        getStorageLocation: { .local },
        updateStorageLocation: { _ in },
        getStorageRoot: { FileManager.default.temporaryDirectory },
        getStorageRootForLocation: { _ in FileManager.default.temporaryDirectory },
        postStorageLocationUpdated: {},
        isDesktop: true
    )
}

private struct StorageDependenciesKey: EnvironmentKey {
    static let defaultValue: StorageDependencies = .preview
}

public extension EnvironmentValues {
    var pluginStorageDependencies: StorageDependencies {
        get { self[StorageDependenciesKey.self] }
        set { self[StorageDependenciesKey.self] = newValue }
    }
}

public extension View {
    func pluginStorageDependencies(_ dependencies: StorageDependencies) -> some View {
        environment(\.pluginStorageDependencies, dependencies)
    }
}
