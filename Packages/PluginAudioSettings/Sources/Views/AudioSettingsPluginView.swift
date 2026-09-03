import CisumUIComponents
import PluginAudio
import SwiftUI

struct AudioSettingsPluginView: View {
    @State private var refreshToken = 0

    var body: some View {
        AudioSettingsView(refreshToken: refreshToken) {
            AudioPlugin.getAudioDisk()
        }
        .modifier(AudioSettingsStorageChangeModifier(refreshToken: $refreshToken))
    }
}

struct AudioSettingsStorageChangeModifier: ViewModifier {
    @Binding var refreshToken: Int

    func body(content: Content) -> some View {
        AudioPluginHost.storageLocationDidChangeNotifications.reduce(AnyView(content)) { partial, name in
            AnyView(partial.onReceive(NotificationCenter.default.publisher(for: name)) { _ in
                refreshToken += 1
            })
        }
    }
}
