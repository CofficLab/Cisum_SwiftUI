import CisumUI
import PluginAudio
import SwiftUI

public actor AudioSettingsPlugin: SuperPlugin {
    public static let shared = AudioSettingsPlugin()
    public static var shouldRegister: Bool { true }
    public static var order: Int { AudioSettingsPluginInfo.order }

    public nonisolated var title: String { AudioSettingsPluginInfo.title }
    public nonisolated var description: String { AudioSettingsPluginInfo.description }
    public nonisolated var iconName: String { AudioSettingsPluginInfo.iconName }

    @MainActor
    public func addSettingView() -> AnyView? {
        AnyView(AudioSettingsPluginView())
    }
}

private struct AudioSettingsPluginView: View {
    @State private var refreshToken = 0

    var body: some View {
        AudioSettingsView(refreshToken: refreshToken) {
            AudioPlugin.getAudioDisk()
        }
        .modifier(AudioSettingsStorageChangeModifier(refreshToken: $refreshToken))
    }
}

private struct AudioSettingsStorageChangeModifier: ViewModifier {
    @Binding var refreshToken: Int

    func body(content: Content) -> some View {
        AudioPluginHost.storageLocationDidChangeNotifications.reduce(AnyView(content)) { partial, name in
            AnyView(partial.onReceive(NotificationCenter.default.publisher(for: name)) { _ in
                refreshToken += 1
            })
        }
    }
}
