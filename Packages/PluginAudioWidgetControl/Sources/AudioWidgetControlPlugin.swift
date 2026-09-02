import CisumUIComponents
import PluginAudio
import SwiftUI

public actor AudioWidgetControlPlugin: SuperPlugin {
    public static let shared = AudioWidgetControlPlugin()
    public static let metadata = PluginMetadata(
        displayName: AudioWidgetControlPluginInfo.title,
        description: AudioWidgetControlPluginInfo.description,
        iconName: AudioWidgetControlPluginInfo.iconName,
        order: 100
    )
    public nonisolated var label: String { "widgetControl" }

    @MainActor
    public func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(
            content()
                .background(
                    AudioWidgetControlRootView(
                        nextAsset: { current, verbose in
                            guard let repo = AudioPlugin.getAudioRepo() else {
                                throw AudioPluginError.hostNotConfigured
                            }
                            return try await repo.getNextOf(current, verbose: verbose)
                        },
                        previousAsset: { current, verbose in
                            guard let repo = AudioPlugin.getAudioRepo() else {
                                throw AudioPluginError.hostNotConfigured
                            }
                            return try await repo.getPrevOf(current, verbose: verbose)
                        },
                        firstAsset: {
                            guard let repo = AudioPlugin.getAudioRepo() else {
                                throw AudioPluginError.hostNotConfigured
                            }
                            return try await repo.getFirst()
                        },
                        lastAsset: {
                            guard let repo = AudioPlugin.getAudioRepo() else {
                                throw AudioPluginError.hostNotConfigured
                            }
                            return try await repo.getLast()
                        }
                    )
                )
        )
    }
}
