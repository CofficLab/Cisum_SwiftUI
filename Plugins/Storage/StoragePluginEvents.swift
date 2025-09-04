
import Foundation
import SwiftUI

// MARK: - Storage Plugin Events

extension Notification.Name {
    /// 存储位置更新通知
    static let storageLocationUpdated = Notification.Name("storageLocationUpdated")
}

// MARK: - Storage Event Keys

struct StorageEventKeys {
    /// 新的存储位置
    static let newLocation = "newLocation"
    /// 旧的存储位置
    static let oldLocation = "oldLocation"
    /// 是否迁移完成
    static let migrationCompleted = "migrationCompleted"
}

// MARK: - View Extensions

extension View {
    /// 监听存储位置变化
    /// - Parameter action: 当存储位置更新时执行的操作
    /// - Parameter newLocation: 新的存储位置
    /// - Parameter oldLocation: 旧的存储位置
    /// - Parameter migrationCompleted: 是否完成了数据迁移
    func onStorageLocationChanged(
        perform action: @escaping (StorageLocation, StorageLocation, Bool) -> Void
    ) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: .storageLocationUpdated)) { notification in
            if let newLocation = notification.userInfo?[StorageEventKeys.newLocation] as? StorageLocation,
               let oldLocation = notification.userInfo?[StorageEventKeys.oldLocation] as? StorageLocation,
               let migrationCompleted = notification.userInfo?[StorageEventKeys.migrationCompleted] as? Bool {
                action(newLocation, oldLocation, migrationCompleted)
            }
        }
    }
    
    /// 监听存储位置变化（简化版本）
    /// - Parameter action: 当存储位置更新时执行的操作
    func onStorageLocationChanged(
        perform action: @escaping () -> Void
    ) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: .storageLocationUpdated)) { _ in
            action()
        }
    }
}
