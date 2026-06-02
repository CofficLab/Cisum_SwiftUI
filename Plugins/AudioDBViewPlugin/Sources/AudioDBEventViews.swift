import AudioPlugin
import SwiftUI

extension View {
    func onDBSynced(perform action: @escaping (Notification) -> Void) -> some View {
        onReceive(NotificationCenter.default.publisher(for: .dbSynced), perform: action)
    }

    func onDBSyncing(perform action: @escaping (Notification) -> Void) -> some View {
        onReceive(NotificationCenter.default.publisher(for: .dbSyncing), perform: action)
    }

    func onDBUpdated(perform action: @escaping (Notification) -> Void) -> some View {
        onReceive(NotificationCenter.default.publisher(for: .dbUpdated), perform: action)
    }

    func onDBDeleted(perform action: @escaping (Notification) -> Void) -> some View {
        onReceive(NotificationCenter.default.publisher(for: .dbDeleted), perform: action)
    }

    func onDBSorting(perform action: @escaping (Notification) -> Void) -> some View {
        onReceive(NotificationCenter.default.publisher(for: .DBSorting), perform: action)
    }

    func onDBSortDone(perform action: @escaping (Notification) -> Void) -> some View {
        onReceive(NotificationCenter.default.publisher(for: .DBSortDone), perform: action)
    }
}
