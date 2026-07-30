import Foundation

/// 云同步服务能力协议。
///
/// 提供 iCloud 账户状态监控与同步进度查询。
///
/// ## 使用示例
///
/// ```swift
/// let isAvailable = kernel.cloud?.isICloudAvailable ?? false
/// let status = kernel.cloud?.accountStatus
/// ```
@MainActor
public protocol CloudProviding: AnyObject, ObservableObject {
    /// iCloud 是否可用。
    var isICloudAvailable: Bool { get }

    /// 当前 iCloud 账户状态。
    var accountStatus: CloudAccountStatus { get }

    /// 是否正在进行同步。
    var isSyncing: Bool { get }

    /// 上一次同步时间。
    var lastSyncDate: Date? { get }
}

/// 云同步账户状态。
public enum CloudAccountStatus: Sendable {
    /// 可用。
    case available
    /// 未登录。
    case notSignedIn
    /// 受限访问。
    case restricted
    /// 未知（尚未确定）。
    case unknown
}
