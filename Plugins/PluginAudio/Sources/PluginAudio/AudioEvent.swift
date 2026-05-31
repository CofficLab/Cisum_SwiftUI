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
        postAudioEventOnMain(name: .dbSyncing)
    }

    static func postDBSynced() {
        postAudioEventOnMain(name: .dbSynced)
    }

    static func postDBUpdated() {
        postAudioEventOnMain(name: .dbUpdated)
    }

    static func postFileSystemSynced() {
        postAudioEventOnMain(name: .fileSystemSynced)
    }

    static func postFileSystemDeleted() {
        postAudioEventOnMain(name: .fileSystemDeleted)
    }

    private static func postAudioEventOnMain(name: Notification.Name) {
        if Thread.isMainThread {
            NotificationCenter.default.post(name: name, object: nil)
        } else {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: name, object: nil)
            }
        }
    }
}
