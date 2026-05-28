import Foundation
import MagicKit
import OSLog
import PluginAudioProgress
import SwiftUI

actor AudioProgressPlugin: SuperPlugin, SuperLog {
    static let shared = AudioProgressPlugin()
    static let emoji = "💾"
    static let verbose = true
    static var shouldRegister: Bool { true }

    /// 注册顺序设为 0，确保在 AudioPlugin (order: 1) 之前执行
    /// 内核会按顺序应用插件，进度管理先于音频功能
    static var order: Int { 0 }

    nonisolated var title: String { String(localized: String.LocalizationValue(AudioProgressPluginInfo.titleKey), table: AudioProgressPluginInfo.table) }
    nonisolated var description: String { String(localized: String.LocalizationValue(AudioProgressPluginInfo.descriptionKey), table: AudioProgressPluginInfo.table) }
    let iconName = "waveform"

    /// 只有当当前插件是音频插件时才提供进度管理
    @MainActor func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(AudioProgressPluginRootView(content: content))
    }
}

private struct AudioProgressPluginRootView<Content>: View where Content: View {
    @EnvironmentObject private var pluginProvider: PluginProvider

    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        AudioProgressRootView(
            currentSceneName: { pluginProvider.currentSceneName },
            audioSceneName: AudioScenePlugin.sceneName,
            audioRepo: { AudioPlugin.getAudioRepo() },
            storageResetNotifications: [.storageLocationDidReset],
            saveWidgetData: { title, artist, isPlaying, coverArt in
                WidgetData.save(title: title, artist: artist, isPlaying: isPlaying, coverArt: coverArt)
            },
            content: { content }
        )
    }
}

// MARK: - Preview

#Preview("App - Large") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
