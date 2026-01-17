import Foundation
import SwiftUI

/// SwiftUI View 扩展，提供便捷的存储相关事件监听
extension View {
    /// 监听存储位置变化
    /// - Parameter action: 当存储位置更新时执行的操作
    func onStorageLocationChanged(perform action: @escaping () -> Void) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: .storageLocationUpdated)) { _ in
            action()
        }
    }
}
