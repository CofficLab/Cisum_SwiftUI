import Foundation
import SwiftUI

/// 音频插件的所有通知名称
/// 统一管理，避免重复定义和命名冲突
extension Notification.Name {
    // MARK: - 音频数据同步相关

    /// 音频列表更新通知
    static let AudiosUpdatedNotification = Notification.Name("AudiosUpdatedNotification")

    /// 单个音频更新通知
    static let AudioUpdatedNotification = Notification.Name("AudioUpdatedNotification")

    /// 同步开始通知
    static let SyncingNotification = Notification.Name("SyncingNotification")

    /// 数据库同步开始
    static let dbSyncing = Notification.Name("dbSyncing")

    /// 数据库同步完成
    static let dbSynced = Notification.Name("dbSynced")

    /// 数据库更新
    static let dbUpdated = Notification.Name("dbUpdated")

    // MARK: - 音频文件操作相关

    /// 单个URL删除通知
    static let URLDeletedNotification = Notification.Name("URLDeletedNotification")

    /// 多个URL删除通知
    static let URLsDeletedNotification = Notification.Name("URLsDeletedNotification")

    /// 数据库删除操作
    static let dbDeleted = Notification.Name("dbDeleted")

    /// 文件复制操作
    static let CopyFiles = Notification.Name("CopyFiles")

    // MARK: - 音频排序相关

    /// 数据库排序开始
    static let DBSorting = Notification.Name("DBSorting")

    /// 数据库排序完成
    static let DBSortDone = Notification.Name("DBSortDone")

    // MARK: - 下载进度相关

    /// 音频下载进度
    static let audioDownloadProgress = Notification.Name("audioDownloadProgress")
}

/// SwiftUI View 扩展，提供便捷的数据库同步事件监听
extension View {
    /// 监听数据库同步完成事件
    /// - Parameter action: 同步完成时执行的操作
    /// - Returns: 添加了监听器的视图
    func onDBSynced(perform action: @escaping (Notification) -> Void) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: .dbSynced), perform: action)
    }

    /// 监听数据库同步开始事件
    /// - Parameter action: 同步开始时执行的操作
    /// - Returns: 添加了监听器的视图
    func onDBSyncing(perform action: @escaping (Notification) -> Void) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: .dbSyncing), perform: action)
    }

    /// 监听数据库更新事件
    /// - Parameter action: 数据库更新时执行的操作
    /// - Returns: 添加了监听器的视图
    func onDBUpdated(perform action: @escaping (Notification) -> Void) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: .dbUpdated), perform: action)
    }

    /// 监听音频列表更新事件
    /// - Parameter action: 音频列表更新时执行的操作
    /// - Returns: 添加了监听器的视图
    func onAudiosUpdated(perform action: @escaping () -> Void) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: .AudiosUpdatedNotification)) { _ in
            action()
        }
    }

    /// 监听单个音频更新事件
    /// - Parameter action: 单个音频更新时执行的操作
    /// - Returns: 添加了监听器的视图
    func onAudioUpdated(perform action: @escaping () -> Void) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: .AudioUpdatedNotification)) { _ in
            action()
        }
    }

    /// 监听书籍数据库同步完成事件
    /// - Parameter action: 书籍数据库同步完成时执行的操作
    /// - Returns: 添加了监听器的视图
    func onBookDBSynced(perform action: @escaping () -> Void) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: .bookDBSynced)) { _ in
            action()
        }
    }

    /// 监听书籍数据库同步开始事件
    /// - Parameter action: 书籍数据库同步开始时执行的操作
    /// - Returns: 添加了监听器的视图
    func onBookDBSyncing(perform action: @escaping () -> Void) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: .bookDBSyncing)) { _ in
            action()
        }
    }

    /// 监听数据库删除事件
    /// - Parameter action: 数据库删除时执行的操作
    /// - Returns: 添加了监听器的视图
    func onDBDeleted(perform action: @escaping (Notification) -> Void) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: .dbDeleted), perform: action)
    }

    /// 监听文件复制事件
    /// - Parameter action: 文件复制时执行的操作
    /// - Returns: 添加了监听器的视图
    func onCopyFiles(perform action: @escaping (Notification) -> Void) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: .CopyFiles), perform: action)
    }

    /// 监听数据库排序开始事件
    /// - Parameter action: 数据库排序开始时执行的操作
    /// - Returns: 添加了监听器的视图
    func onDBSorting(perform action: @escaping (Notification) -> Void) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: .DBSorting), perform: action)
    }

    /// 监听数据库排序完成事件
    /// - Parameter action: 数据库排序完成时执行的操作
    /// - Returns: 添加了监听器的视图
    func onDBSortDone(perform action: @escaping (Notification) -> Void) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: .DBSortDone), perform: action)
    }

    /// 监听音频下载进度事件
    /// - Parameter action: 音频下载进度更新时执行的操作
    /// - Returns: 添加了监听器的视图
    func onAudioDownloadProgress(perform action: @escaping () -> Void) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: .audioDownloadProgress)) { _ in
            action()
        }
    }
}

#Preview("Small Screen") {
    RootView {
        UserDefaultsDebugView(defaultSearchText: "AudioPlugin")
    }
    .frame(width: 500)
    .frame(height: 600)
}

#Preview("Big Screen") {
    RootView {
        UserDefaultsDebugView()
    }
    .frame(width: 800)
    .frame(height: 1200)
}
