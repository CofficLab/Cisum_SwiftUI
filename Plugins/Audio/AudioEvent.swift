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
