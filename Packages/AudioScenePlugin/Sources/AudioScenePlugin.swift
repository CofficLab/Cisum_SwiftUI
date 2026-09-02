import CisumUI
import SwiftUI

public actor AudioScenePlugin: SuperPlugin {
    public static let shared = AudioScenePlugin()
    public static let metadata = PluginMetadata(
        displayName: AudioScenePluginInfo.title,
        description: AudioScenePluginInfo.description,
        iconName: AudioScenePluginInfo.iconName,
        order: AudioScenePluginInfo.order
    )
    public static let sceneName = AudioScenePluginInfo.sceneName

    @MainActor
    public func addSceneItem() -> String? {
        Self.sceneName
    }

    @MainActor
    public func addPosterView() -> AnyView? {
        AnyView(AudioScenePluginPosterView())
    }
}
