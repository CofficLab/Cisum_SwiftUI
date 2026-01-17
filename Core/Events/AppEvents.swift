import Foundation
import SwiftUI

/// SwiftUI View 扩展，提供便捷的应用生命周期事件监听
extension View {
    /// 监听应用启动完成事件
    /// - Parameter action: 应用启动完成时执行的操作
    /// - Returns: 添加了监听器的视图
    func onLaunchDone(perform action: @escaping () -> Void) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: .launchDone)) { _ in
            action()
        }
    }
}
