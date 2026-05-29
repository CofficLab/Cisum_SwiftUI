import Foundation
import SwiftUI

extension Notification.Name {
    static let pluginStorageLocationUpdated = Notification.Name("storageLocationUpdated")
}

extension View {
    func onPluginStorageLocationChanged(perform action: @escaping () -> Void) -> some View {
        onReceive(NotificationCenter.default.publisher(for: .pluginStorageLocationUpdated)) { _ in
            action()
        }
    }
}
