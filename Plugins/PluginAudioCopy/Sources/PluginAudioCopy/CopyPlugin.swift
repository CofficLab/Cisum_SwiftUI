import CisumUI
import PluginAudio
import SwiftUI

#if os(macOS)
    public actor CopyPlugin: SuperPlugin {
        public static let shared = CopyPlugin()
        public static var shouldRegister: Bool { true }
        public static var order: Int { 0 }

        public nonisolated var description: String {
            String(localized: String.LocalizationValue(AudioCopyPluginInfo.descriptionKey), table: AudioCopyPluginInfo.table, bundle: .module)
        }

        public nonisolated var iconName: String { AudioCopyPluginInfo.iconName }

        @MainActor
        public func addStateView(currentSceneName: String?) -> AnyView? {
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
                    guard let repo = AudioPlugin.getAudioRepo() else {
                        return 0
                    }
                    return await repo.getTotalCount()
                }
            )
        }
    }
#endif
