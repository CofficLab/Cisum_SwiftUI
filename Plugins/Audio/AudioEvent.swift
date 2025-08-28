import Foundation
import SwiftUI

extension Notification.Name {
    static let AudiosUpdatedNotification = Notification.Name("AudiosUpdatedNotification")
    static let AudioUpdatedNotification = Notification.Name("AudioUpdatedNotification")
    static let SyncingNotification = Notification.Name("SyncingNotification")
    static let URLDeletedNotification = Notification.Name("URLDeletedNotification")
    static let URLsDeletedNotification = Notification.Name("URLsDeletedNotification")
}

extension Notification.Name {
    static let DBSorting = Notification.Name("DBSorting")
    static let DBSortDone = Notification.Name("DBSortDone")
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
