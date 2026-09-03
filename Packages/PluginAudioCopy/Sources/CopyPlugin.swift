import CisumUIComponents
import KernelCore
import ProviderDocsView
import PluginAudio
import SwiftUI

#if os(macOS)
    public actor CopyPlugin: SuperPlugin {
        public static let shared = CopyPlugin()
        public static let metadata = PluginMetadata(
            displayName: String(localized: "Copy", bundle: .module),
            description: String(localized: String.LocalizationValue(AudioCopyPluginInfo.descriptionKey), bundle: .module),
            iconName: AudioCopyPluginInfo.iconName,
            order: 0,
        category: .tool,
        )


    @MainActor
    public func onRegister(kernel: CisumKernel) async throws {
        if let docs = kernel.docs {
            docs.addAbout(DocsEntry(id: self.id, name: Self.metadata.displayName) { CopyPluginAboutView() })
            docs.addManual(DocsEntry(id: self.id, name: Self.metadata.displayName) { CopyPluginManualView() })
        }
    }

        @MainActor
        public func addStateView() -> AnyView? {
            configureService()
            return AudioCopyService.getStateView()
        }

        @MainActor
        public func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
            configureService()
            return AudioCopyService.getRootView { content() }
        }

        @MainActor
        private func configureService() {
            AudioCopyService.configure(
                audioDiskProvider: {
                    AudioPlugin.getAudioDisk()
                },
                audioCountProvider: {
                    guard let repo = await AudioPlugin.getAudioRepoAsync() else {
                        return 0
                    }
                    return await repo.getTotalCount()
                }
            )
        }
    }
#endif
