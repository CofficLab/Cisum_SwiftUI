import Foundation
import MagicKit
import OSLog
import PluginAudioCopy
import PluginAudio
import SwiftUI

#if os(macOS)
    actor CopyPlugin: SuperPlugin, SuperLog {
        static let shared = CopyPlugin()
        static let emoji = "🚛"
        static let verbose = true
        static var shouldRegister: Bool { true }
        static var order: Int { 0 }

        let description: String = String(localized: String.LocalizationValue(AudioCopyPluginInfo.descriptionKey), table: AudioCopyPluginInfo.table)
        let iconName: String = AudioCopyPluginInfo.iconName

        @MainActor func addStateView(currentSceneName: String?) -> AnyView? {
            configureService()
            return AudioCopyService.getStateView()
        }

        @MainActor func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
            configureService()
            return AudioCopyService.getRootView { content() }
        }

        @MainActor private func configureService() {
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
