import Foundation
import PluginAudioWidgetControl
import SwiftUI
import PluginAudio

actor AudioWidgetControlPlugin: SuperPlugin {
    static let shared = AudioWidgetControlPlugin()
    nonisolated static let emoji = "🎛️"
    nonisolated static let order = 100

    nonisolated var id: String {
        "AudioWidgetControlPlugin"
    }

    nonisolated var label: String {
        "widgetControl"
    }

    nonisolated var title: String {
        AudioWidgetControlPluginInfo.title
    }

    nonisolated var description: String {
        AudioWidgetControlPluginInfo.description
    }

    nonisolated var iconName: String {
        AudioWidgetControlPluginInfo.iconName
    }

    nonisolated static var shouldRegister: Bool {
        true
    }

    @MainActor func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
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
