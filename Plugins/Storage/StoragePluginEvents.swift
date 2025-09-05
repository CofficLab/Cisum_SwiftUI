
import Foundation
import SwiftUI

// MARK: - Storage Plugin Events

extension Notification.Name {
    /// 存储位置更新通知
    static let storageLocationUpdated = Notification.Name("storageLocationUpdated")
}

// MARK: - View Extensions

extension View {
    /// 监听存储位置变化
    /// - Parameter action: 当存储位置更新时执行的操作
    func onStorageLocationChanged(
        perform action: @escaping () -> Void
    ) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: .storageLocationUpdated)) { _ in
            action()
        }
    }
    
}
