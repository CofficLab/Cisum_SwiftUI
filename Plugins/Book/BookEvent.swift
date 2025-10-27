import Foundation
import SwiftUI

// MARK: - Event

/// 书籍插件的所有通知名称
/// 统一管理，避免重复定义和命名冲突
extension Notification.Name {
    // MARK: - 书籍数据同步相关
    
    /// 数据库同步开始
    static let bookDBSyncing = Notification.Name("bookDBSyncing")
    
    /// 数据库同步完成
    static let bookDBSynced = Notification.Name("bookDBSynced")
    
    /// 数据库更新
    static let bookDBUpdated = Notification.Name("bookDBUpdated")
    
    // MARK: - 书籍文件操作相关
    
    /// 数据库删除操作
    static let bookDBDeleted = Notification.Name("bookDBDeleted")
    
    // MARK: - 书籍排序相关
    
    /// 数据库排序开始
    static let bookDBSorting = Notification.Name("bookDBSorting")
    
    /// 数据库排序完成
    static let bookDBSortDone = Notification.Name("bookDBSortDone")
}

// MARK: - Event Handler

/// SwiftUI View 扩展，提供便捷的数据库事件监听
extension View {
    /// 监听数据库同步完成事件
    /// - Parameter action: 同步完成时执行的操作
    /// - Returns: 添加了监听器的视图
    func onBookDBSynced(perform action: @escaping (Notification) -> Void) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: .bookDBSynced), perform: action)
    }

    /// 监听数据库同步开始事件
    /// - Parameter action: 同步开始时执行的操作
    /// - Returns: 添加了监听器的视图
    func onBookDBSyncing(perform action: @escaping (Notification) -> Void) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: .bookDBSyncing), perform: action)
    }
    
    /// 监听数据库更新事件
    /// - Parameter action: 数据库更新时执行的操作
    /// - Returns: 添加了监听器的视图
    func onBookDBUpdated(perform action: @escaping (Notification) -> Void) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: .bookDBUpdated), perform: action)
    }
    
    /// 监听数据库删除事件
    /// - Parameter action: 数据库删除时执行的操作
    /// - Returns: 添加了监听器的视图
    func onBookDBDeleted(perform action: @escaping (Notification) -> Void) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: .bookDBDeleted), perform: action)
    }
    
    /// 监听数据库排序开始事件
    /// - Parameter action: 数据库排序开始时执行的操作
    /// - Returns: 添加了监听器的视图
    func onBookDBSorting(perform action: @escaping (Notification) -> Void) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: .bookDBSorting), perform: action)
    }
    
    /// 监听数据库排序完成事件
    /// - Parameter action: 数据库排序完成时执行的操作
    /// - Returns: 添加了监听器的视图
    func onBookDBSortDone(perform action: @escaping (Notification) -> Void) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: .bookDBSortDone), perform: action)
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
