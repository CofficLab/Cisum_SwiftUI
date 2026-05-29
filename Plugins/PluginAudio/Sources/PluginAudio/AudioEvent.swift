import Foundation

public extension Notification.Name {
    static let AudiosUpdatedNotification = Notification.Name("AudiosUpdatedNotification")
    static let AudioUpdatedNotification = Notification.Name("AudioUpdatedNotification")
    static let SyncingNotification = Notification.Name("SyncingNotification")
    static let dbSyncing = Notification.Name("dbSyncing")
    static let dbSynced = Notification.Name("dbSynced")
    static let dbUpdated = Notification.Name("dbUpdated")
    static let fileSystemSynced = Notification.Name("fileSystemSynced")
    static let fileSystemDeleted = Notification.Name("fileSystemDeleted")
    static let URLDeletedNotification = Notification.Name("URLDeletedNotification")
    static let URLsDeletedNotification = Notification.Name("URLsDeletedNotification")
    static let dbDeleted = Notification.Name("dbDeleted")
    static let CopyFiles = Notification.Name("CopyFiles")
    static let DBSorting = Notification.Name("DBSorting")
    static let DBSortDone = Notification.Name("DBSortDone")
    static let audioDownloadProgress = Notification.Name("audioDownloadProgress")
}

public extension NotificationCenter {
    static func postDBSyncing() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .dbSyncing, object: nil)
        }
    }

    static func postDBSynced() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .dbSynced, object: nil)
        }
    }

    static func postDBUpdated() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .dbUpdated, object: nil)
        }
    }

    static func postFileSystemSynced() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .fileSystemSynced, object: nil)
        }
    }

    static func postFileSystemDeleted() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .fileSystemDeleted, object: nil)
        }
    }
}
