import Foundation
import SwiftUI

/// SwiftUI View 扩展，提供便捷的配置相关事件监听
extension View {
    /// 监听存储位置重置事件
    /// - Parameter action: 存储位置重置时执行的操作
    /// - Returns: 添加了监听器的视图
    func onStorageLocationDidReset(perform action: @escaping () -> Void) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: Config.storageLocationDidReset)) { _ in
            action()
        }
    }
}
