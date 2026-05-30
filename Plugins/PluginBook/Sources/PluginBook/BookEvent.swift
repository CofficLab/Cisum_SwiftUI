import Foundation

// MARK: - Event

/// 书籍插件的所有通知名称
/// 统一管理，避免重复定义和命名冲突
public extension Notification.Name {
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

public extension NotificationCenter {
    static func postBookDBSyncing() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .bookDBSyncing, object: nil)
        }
    }

    static func postBookDBSynced() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .bookDBSynced, object: nil)
        }
    }

    static func postBookDBUpdated() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .bookDBUpdated, object: nil)
        }
    }

    static func postBookDBDeleted() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .bookDBDeleted, object: nil)
        }
    }

    static func postBookDBSorting() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .bookDBSorting, object: nil)
        }
    }

    static func postBookDBSortDone() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .bookDBSortDone, object: nil)
        }
    }
}

// MARK: - Event Handler
