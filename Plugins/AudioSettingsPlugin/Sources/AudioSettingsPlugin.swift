import CisumUI
import AudioPlugin
import SwiftUI

public actor AudioSettingsPlugin: SuperPlugin {
    public static let shared = AudioSettingsPlugin()
    public static let metadata = PluginMetadata(
        id: "AudioSettingsPlugin",
        displayName: AudioSettingsPluginInfo.title,
        description: AudioSettingsPluginInfo.description,
        iconName: AudioSettingsPluginInfo.iconName,
        order: AudioSettingsPluginInfo.order
    )

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
