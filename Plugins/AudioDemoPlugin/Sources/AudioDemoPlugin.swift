import CisumUI
import AudioScenePlugin
import SwiftUI

public actor AudioDemoPlugin: SuperPlugin {
    public static let shared = AudioDemoPlugin()

    public static var shouldRegister: Bool { true }
    public static var order: Int { 1 }

    public nonisolated var title: String { AudioDemoPluginInfo.title }
    public nonisolated var description: String { AudioDemoPluginInfo.description }
    public nonisolated var iconName: String { AudioDemoPluginInfo.iconName }

    @MainActor
    public func addTabView(reason: String, currentSceneName: String?, demoMode: Bool = false) -> (view: AnyView, label: String)? {
        guard currentSceneName == AudioScenePlugin.sceneName else { return nil }
        guard demoMode else { return nil }

        let addButton = AnyView(
            AudioDemoAddButton()
                .font(.title2)
                .labelStyle(.iconOnly)
        )

        return (
            AnyView(AudioListDemo(showAddButton: Self.isNotDesktop, addButton: addButton)),
            AudioDemoPluginInfo.tabLabel
        )
    }

    private static var isNotDesktop: Bool {
        #if os(macOS)
            false
        #else
            true
        #endif
    }
}

private struct AudioDemoAddButton: View {
    @Environment(\.appIsImporting) private var isImporting

    var body: some View {
        Button(
            action: { isImporting.wrappedValue = true },
            label: {
                Label(
                    title: { Text("Add", bundle: .module) },
                    icon: { Image(systemName: "plus.circle") }
                )
            }
        )
    }
}
