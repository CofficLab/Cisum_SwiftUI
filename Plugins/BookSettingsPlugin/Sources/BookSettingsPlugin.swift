import CisumUI
import BookPlugin
import SwiftUI

public actor BookSettingsPlugin: SuperPlugin {
    public static let shared = BookSettingsPlugin()
    public static let metadata = PluginMetadata(
        id: "BookSettingsPlugin",
        displayName: BookSettingsPluginInfo.title,
        description: BookSettingsPluginInfo.description,
        iconName: BookSettingsPluginInfo.iconName,
        order: BookSettingsPluginInfo.order
    )

    @MainActor
    public func addSettingView() -> AnyView? {
        AnyView(BookSettingsPluginView())
    }
}

private struct BookSettingsPluginView: View {
    @State private var refreshToken = 0

    var body: some View {
        BookSettingsView(refreshToken: refreshToken) {
            BookPlugin.getBookDisk()
        }
        .modifier(BookSettingsStorageChangeModifier(refreshToken: $refreshToken))
    }
}

private struct BookSettingsStorageChangeModifier: ViewModifier {
    @Binding var refreshToken: Int

    func body(content: Content) -> some View {
        BookPluginHost.storageLocationDidChangeNotifications.reduce(AnyView(content)) { partial, name in
            AnyView(partial.onReceive(NotificationCenter.default.publisher(for: name)) { _ in
                refreshToken += 1
            })
        }
    }
}
