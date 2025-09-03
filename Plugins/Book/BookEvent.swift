import Foundation
import SwiftUI

// MARK: Event

extension Notification.Name {
    static let bookDBSyncing = Notification.Name("bookDBSyncing")
    static let bookDBSynced = Notification.Name("bookDBSynced")
}

// MARK: - Event Handler
extension View {
    /// 监听书籍数据库同步完成事件
    /// - Parameter action: 同步完成时执行的操作
    /// - Returns: 添加了监听器的视图
    func onBookDBSynced(perform action: @escaping () -> Void) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: .bookDBSynced)) { _ in
            action()
        }
    }

    /// 监听书籍数据库同步开始事件
    /// - Parameter action: 同步开始时执行的操作
    /// - Returns: 添加了监听器的视图
    func onBookDBSyncing(perform action: @escaping () -> Void) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: .bookDBSyncing)) { _ in
            action()
        }
    }
}

#if os(macOS)
    #Preview("App - Large") {
        AppPreview()
            .frame(width: 600, height: 1000)
    }

    #Preview("App - Small") {
        AppPreview()
            .frame(width: 500, height: 800)
    }
#endif

#if os(iOS)
    #Preview("iPhone") {
        AppPreview()
    }
#endif
