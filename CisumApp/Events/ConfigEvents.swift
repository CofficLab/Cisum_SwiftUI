import Foundation
import SwiftUI

// MARK: - Notification Names

extension Notification.Name {
    /// 配置更新通知
    static let configUpdated = Notification.Name("configUpdated")

    /// 设置变更通知
    static let settingsChanged = Notification.Name("settingsChanged")
}

// MARK: - NotificationCenter Extensions

/// NotificationCenter 扩展，提供便捷的配置事件发送方法
extension NotificationCenter {
    /// 发送配置更新事件
    static func postConfigUpdated() {
        postConfigEventOnMain(name: .configUpdated)
    }

    /// 发送设置变更事件
    static func postSettingsChanged() {
        postConfigEventOnMain(name: .settingsChanged)
    }

    private static func postConfigEventOnMain(name: Notification.Name) {
        if Thread.isMainThread {
            NotificationCenter.default.post(name: name, object: nil)
        } else {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: name, object: nil)
            }
        }
    }
}

// MARK: - View Extensions

/// SwiftUI View 扩展，提供便捷的配置相关事件监听
extension View {
    /// 监听配置更新事件
    /// - Parameter action: 配置更新时执行的操作
    func onConfigUpdated(perform action: @escaping () -> Void) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: .configUpdated)) { _ in
            action()
        }
    }

    /// 监听设置变更事件
    /// - Parameter action: 设置变更时执行的操作
    func onSettingsChanged(perform action: @escaping () -> Void) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: .settingsChanged)) { _ in
            action()
        }
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
