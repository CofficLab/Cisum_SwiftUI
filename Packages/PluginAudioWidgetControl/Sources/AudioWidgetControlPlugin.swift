import CisumUIComponents
import KernelCore
import ProviderDocsView
import PluginAudio
import SwiftUI

public actor AudioWidgetControlPlugin: SuperPlugin {
    public static let shared = AudioWidgetControlPlugin()
    public static let metadata = PluginMetadata(
        displayName: AudioWidgetControlPluginInfo.title,
        description: AudioWidgetControlPluginInfo.description,
        iconName: AudioWidgetControlPluginInfo.iconName,
        order: 100,
        category: .tool,
    )

    @MainActor
    public func onRegister(kernel: CisumKernel) async throws {
        if let docs = kernel.docs {
            docs.addAbout(DocsEntry(id: self.id, name: Self.metadata.displayName) { AudioWidgetControlPluginAboutView() })
            docs.addManual(DocsEntry(id: self.id, name: Self.metadata.displayName) { AudioWidgetControlPluginManualView() })
        }
    }

    public nonisolated var label: String { "widgetControl" }

    @MainActor
    public func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(
            content()
                .background(
                    AudioWidgetControlRootView(
                        nextAsset: { current, verbose in
                            guard let repo = await AudioPlugin.getAudioRepoAsync() else {
                                throw AudioPluginError.hostNotConfigured
                            }
                            return try await repo.getNextOf(current, verbose: verbose)
                        },
                        previousAsset: { current, verbose in
                            guard let repo = await AudioPlugin.getAudioRepoAsync() else {
                                throw AudioPluginError.hostNotConfigured
                            }
                            return try await repo.getPrevOf(current, verbose: verbose)
                        },
                        firstAsset: {
                            guard let repo = await AudioPlugin.getAudioRepoAsync() else {
                                throw AudioPluginError.hostNotConfigured
                            }
                            return try await repo.getFirst()
                        },
                        lastAsset: {
                            guard let repo = await AudioPlugin.getAudioRepoAsync() else {
                                throw AudioPluginError.hostNotConfigured
                            }
                            return try await repo.getLast()
                        }
                    )
                )
        )
    }
}
