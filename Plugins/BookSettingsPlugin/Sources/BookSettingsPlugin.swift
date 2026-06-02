import CisumUI
import BookPlugin
import SwiftUI

public actor BookSettingsPlugin: SuperPlugin {
    public static let shared = BookSettingsPlugin()
    public static var shouldRegister: Bool { true }
    public static var order: Int { BookSettingsPluginInfo.order }

    public nonisolated var title: String { BookSettingsPluginInfo.title }
    public nonisolated var description: String { BookSettingsPluginInfo.description }
    public nonisolated var iconName: String { BookSettingsPluginInfo.iconName }

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
