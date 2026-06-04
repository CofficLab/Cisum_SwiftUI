import CisumUI
import AudioScenePlugin
import SwiftUI

public actor AudioDemoPlugin: SuperPlugin {
    public static let shared = AudioDemoPlugin()
    public static let metadata = PluginMetadata(
        displayName: AudioDemoPluginInfo.title,
        description: AudioDemoPluginInfo.description,
        iconName: AudioDemoPluginInfo.iconName,
        order: 1
    )

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
