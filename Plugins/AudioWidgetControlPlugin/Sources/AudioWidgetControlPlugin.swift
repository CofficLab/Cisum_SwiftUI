import CisumUI
import AudioPlugin
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
