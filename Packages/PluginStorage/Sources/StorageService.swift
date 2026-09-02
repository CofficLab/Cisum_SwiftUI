import CisumKernel
import Foundation
import MagicKit

/// `StorageProviding` 的具体实现。
///
/// 吸收了旧版 `Config` 的存储位置逻辑（iCloud / 本地 / 自定义）与数据库目录
/// 管理，成为存储能力的唯一数据源。保持向后兼容：
/// - `UserDefaults` key `"StorageLocation"`（与旧版 `Config` 一致）。
/// - 存储变更通过内核事件 `.cisumStorageLocationDidChange` / `.cisumStorageLocationDidReset` 广播。
@MainActor
public final class StorageService: ObservableObject, StorageProviding {
    private static let storageLocationKey = "StorageLocation"

    private let dbDirName: String

    /// 缓存的数据库根目录（init 时尽力创建）。
    public let databaseRoot: URL

    public init() {
        #if DEBUG
            dbDirName = "db_debug"
        #else
            dbDirName = "db_production"
        #endif

        let root = MagicApp.getDatabaseDirectory()
            .appendingPathComponent(dbDirName, isDirectory: true)
        try? FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        databaseRoot = root
    }

    public var currentStorageLocation: StorageLocation? {
        guard let raw = UserDefaults.standard.string(forKey: Self.storageLocationKey),
              let location = StorageLocation(rawValue: raw) else { return nil }
        guard storageRoot(for: location) != nil else { return nil }
        return location
    }

    public var storageRoot: URL? {
        guard let location = currentStorageLocation else { return nil }
        return storageRoot(for: location)
    }

    public func storageRoot(for location: StorageLocation) -> URL? {
        switch location {
        case .icloud: MagicApp.getCloudDocumentsDirectory()
        case .local: MagicApp.getDocumentsDirectory()
        case .custom: nil
        }
    }

    public var hasUsableStorageLocation: Bool { currentStorageLocation != nil }

    public var isICloudStorageAvailable: Bool { storageRoot(for: .icloud) != nil }

    public func databaseFile(name: String) throws -> URL {
        let dir = databaseRoot.appendingPathComponent(name, isDirectory: true)
        try Self.ensureDirectory(at: dir)
        return dir.appendingPathComponent("\(name).db")
    }

    public func setStorageLocation(_ location: StorageLocation?) {
        UserDefaults.standard.set(location?.rawValue, forKey: Self.storageLocationKey)
        NotificationCenter.default.post(name: .cisumStorageLocationDidChange, object: nil)
    }

    public func resetStorageLocation() {
        UserDefaults.standard.removeObject(forKey: Self.storageLocationKey)
        NotificationCenter.default.post(name: .cisumStorageLocationDidReset, object: nil)
    }

    // MARK: - Bridging（为旧版 `StorageDependencies` 视图提供兼容入口）

    /// 由插件在 `onBoot` 设置，供 `StoragePlugin.addSettingView` 构建旧版依赖闭包使用。
    nonisolated(unsafe) public static var current: StorageService?

    /// 构建旧版 `StorageDependencies`，桥接到当前 `StorageService`。
    public static func makePluginDependencies() -> StorageDependencies {
        StorageDependencies(
            getStorageLocation: { current?.currentStorageLocation.map { StoragePluginLocation($0) } },
            updateStorageLocation: { current?.setStorageLocation($0.map { StorageLocation($0) }) },
            getStorageRoot: { current?.storageRoot },
            getStorageRootForLocation: { current?.storageRoot(for: StorageLocation($0)) },
            postStorageLocationUpdated: {
                NotificationCenter.default.post(name: .cisumStorageLocationDidChange, object: nil)
            },
            isDesktop: MagicApp.isDesktop
        )
    }

    private static func ensureDirectory(at url: URL) throws {
        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory), !isDirectory.boolValue {
            try FileManager.default.removeItem(at: url)
        } else if (try? FileManager.default.destinationOfSymbolicLink(atPath: url.path)) != nil {
            try FileManager.default.removeItem(at: url)
        }
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
}

// MARK: - StorageLocation ↔ StoragePluginLocation

public extension StoragePluginLocation {
    init(_ location: StorageLocation) {
        self = StoragePluginLocation(rawValue: location.rawValue) ?? .local
    }
}

public extension StorageLocation {
    init(_ location: StoragePluginLocation) {
        self = StorageLocation(rawValue: location.rawValue) ?? .local
    }
}
