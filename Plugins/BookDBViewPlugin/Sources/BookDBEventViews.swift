import Foundation
import BookPlugin
import SwiftUI

extension View {
    func onBookDBSynced(perform action: @escaping (Notification) -> Void) -> some View {
        onReceive(NotificationCenter.default.publisher(for: .bookDBSynced), perform: action)
    }

    func onBookDBSyncing(perform action: @escaping (Notification) -> Void) -> some View {
        onReceive(NotificationCenter.default.publisher(for: .bookDBSyncing), perform: action)
    }

    func onBookDBUpdated(perform action: @escaping (Notification) -> Void) -> some View {
        onReceive(NotificationCenter.default.publisher(for: .bookDBUpdated), perform: action)
    }

    func onBookDBDeleted(perform action: @escaping (Notification) -> Void) -> some View {
        onReceive(NotificationCenter.default.publisher(for: .bookDBDeleted), perform: action)
    }

    func onBookDBSorting(perform action: @escaping (Notification) -> Void) -> some View {
        onReceive(NotificationCenter.default.publisher(for: .bookDBSorting), perform: action)
    }

    func onBookDBSortDone(perform action: @escaping (Notification) -> Void) -> some View {
        onReceive(NotificationCenter.default.publisher(for: .bookDBSortDone), perform: action)
    }
}
