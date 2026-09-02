import CisumUI
import PluginBook
import SwiftUI

struct BookSettingsPluginView: View {
    @State private var refreshToken = 0

    var body: some View {
        BookSettingsView(refreshToken: refreshToken) {
            BookPlugin.getBookDisk()
        }
        .modifier(BookSettingsStorageChangeModifier(refreshToken: $refreshToken))
    }
}

struct BookSettingsStorageChangeModifier: ViewModifier {
    @Binding var refreshToken: Int

    func body(content: Content) -> some View {
        BookPluginHost.storageLocationDidChangeNotifications.reduce(AnyView(content)) { partial, name in
            AnyView(partial.onReceive(NotificationCenter.default.publisher(for: name)) { _ in
                refreshToken += 1
            })
        }
    }
}
