import Foundation
import SwiftUI

/// SwiftUI View 扩展，提供便捷的音频数据库同步事件监听
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

    /// 监听音频下载进度事件（带进度信息）
    /// - Parameter action: 接收进度信息的操作，参数为 (url: URL, progress: Double)
    /// - Returns: 添加了监听器的视图
    func onAudioDownloadProgress(perform action: @escaping (URL, Double) -> Void) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: .audioDownloadProgress)) { notification in
            guard
                let eventURL = notification.userInfo?["url"] as? URL,
                let progress = notification.userInfo?["progress"] as? Double
            else { return }

            action(eventURL, progress)
        }
    }
}
