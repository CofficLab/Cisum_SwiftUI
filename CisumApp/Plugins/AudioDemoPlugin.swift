import PluginAudioDemo
import SwiftUI

actor AudioDemoPlugin: SuperPlugin {
    static let shared = AudioDemoPlugin()

    static var shouldRegister: Bool { true }
    static var order: Int { 1 }

    nonisolated var title: String { AudioDemoPluginInfo.title }
    nonisolated var description: String { AudioDemoPluginInfo.description }
    nonisolated var iconName: String { AudioDemoPluginInfo.iconName }

    @MainActor
    func addTabView(reason: String, currentSceneName: String?, demoMode: Bool = false) -> (view: AnyView, label: String)? {
        guard currentSceneName == AudioScenePlugin.sceneName else { return nil }
        guard demoMode else { return nil }

        let addButton = AnyView(
            AudioDemoAddButton()
                .font(.title2)
                .labelStyle(.iconOnly)
        )

        return (
            AnyView(AudioListDemo(showAddButton: Config.isNotDesktop, addButton: addButton)),
            AudioDemoPluginInfo.tabLabel
        )
    }
}

private struct AudioDemoAddButton: View {
    @EnvironmentObject private var app: AppProvider

    var body: some View {
        Button(
            action: { app.isImporting = true },
            label: {
                Label(
                    title: { Text("添加", tableName: "Audio-DBView") },
                    icon: { Image(systemName: "plus.circle") }
                )
            }
        )
    }
}
