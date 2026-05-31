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
        postBookEventOnMain(name: .bookDBSyncing)
    }

    static func postBookDBSynced() {
        postBookEventOnMain(name: .bookDBSynced)
    }

    static func postBookDBUpdated() {
        postBookEventOnMain(name: .bookDBUpdated)
    }

    static func postBookDBDeleted(urls: [URL] = []) {
        postBookDeletedEventOnMain(urls: urls)
    }

    static func postBookDBSorting() {
        postBookEventOnMain(name: .bookDBSorting)
    }

    static func postBookDBSortDone() {
        postBookEventOnMain(name: .bookDBSortDone)
    }

    private static func postBookEventOnMain(name: Notification.Name) {
        if Thread.isMainThread {
            NotificationCenter.default.post(name: name, object: nil)
        } else {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: name, object: nil)
            }
        }
    }

    private static func postBookDeletedEventOnMain(urls: [URL]) {
        if Thread.isMainThread {
            NotificationCenter.default.post(name: .bookDBDeleted, object: nil, userInfo: ["urls": urls])
        } else {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .bookDBDeleted, object: nil, userInfo: ["urls": urls])
            }
        }
    }
}

// MARK: - Event Handler
