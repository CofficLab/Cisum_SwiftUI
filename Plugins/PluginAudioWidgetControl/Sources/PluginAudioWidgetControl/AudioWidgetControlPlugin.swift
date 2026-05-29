import CisumUI
import PluginAudio
import SwiftUI

public actor AudioWidgetControlPlugin: SuperPlugin {
    public static let shared = AudioWidgetControlPlugin()
    public static let order = 100
    public static var shouldRegister: Bool { true }

    public nonisolated var id: String { "AudioWidgetControlPlugin" }
    public nonisolated var label: String { "widgetControl" }
    public nonisolated var title: String { AudioWidgetControlPluginInfo.title }
    public nonisolated var description: String { AudioWidgetControlPluginInfo.description }
    public nonisolated var iconName: String { AudioWidgetControlPluginInfo.iconName }

    @MainActor
    public func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(
            content()
                .background(
                    AudioWidgetControlRootView(
                        nextAsset: { current, verbose in
                            try await AudioPlugin.getAudioRepo()?.getNextOf(current, verbose: verbose)
                        },
                        previousAsset: { current, verbose in
                            try await AudioPlugin.getAudioRepo()?.getPrevOf(current, verbose: verbose)
                        },
                        firstAsset: {
                            try await AudioPlugin.getAudioRepo()?.getFirst()
                        }
                    )
                )
        )
    }
}
