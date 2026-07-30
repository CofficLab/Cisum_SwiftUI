import Foundation

/// 存储服务能力协议。
///
/// 管理应用的持久化存储位置（iCloud / 本地 / 自定义路径）。
///
/// ## 使用示例
///
/// ```swift
/// let location = kernel.storage?.currentLocation
/// kernel.storage?.setLocation(.local)
/// ```
@MainActor
public protocol StorageProviding: AnyObject {
    /// 当前存储位置类型。
    var currentStorageKind: StorageKind { get }

    /// 当前存储位置的 URL。
    var currentStorageURL: URL { get }

    /// 切换存储位置。
    ///
    /// - Parameter kind: 新的存储位置类型。
    func setStorageKind(_ kind: StorageKind) async throws

    /// 是否有可用的存储位置配置。
    var hasUsableStorage: Bool { get }
}

/// 存储位置类型。
public enum StorageKind: String, Sendable, Codable {
    case icloud
    case local
    case custom

    /// 显示用标题。
    public var title: String {
        switch self {
        case .icloud: "iCloud"
        case .local: "Local"
        case .custom: "Custom"
        }
    }

    /// 显示用描述。
    public var description: String {
        switch self {
        case .icloud: "Use iCloud for data storage"
        case .local: "Use local storage for data"
        case .custom: "Use custom storage location for data"
        }
    }
}
