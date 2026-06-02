import Foundation
import SwiftUI

extension Notification.Name {
    static let cisumThemeDidChange = Notification.Name("cisumThemeDidChange")
}

extension View {
    func onCisumThemeDidChange(perform action: @escaping (Notification) -> Void) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: .cisumThemeDidChange), perform: action)
    }
}
