import MagicKit
import OSLog
import PluginAudioDBView
import SwiftUI
import PluginAudio

/**
 * 音频数据库插件：提供音频仓库列表视图。
 */
actor AudioDBPlugin: SuperPlugin {
    static let shared = AudioDBPlugin()
    static var shouldRegister: Bool { true }
    static var order: Int { 1 }

    nonisolated var title: String { String(localized: String.LocalizationValue(AudioDBPluginInfo.titleKey), table: AudioDBPluginInfo.table) }
    nonisolated var description: String { String(localized: String.LocalizationValue(AudioDBPluginInfo.descriptionKey), table: AudioDBPluginInfo.table) }
    let iconName = "externaldrive"

    @MainActor
    func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(AudioDBPluginRootView(content: content))
    }

    @MainActor
    func addTabView(reason: String, currentSceneName: String?, demoMode: Bool = false) -> (view: AnyView, label: String)? {
        guard currentSceneName == AudioScenePlugin.sceneName else { return nil }
        guard demoMode == false else { return nil }

        return (AnyView(AudioDBPluginTabView(demoMode: demoMode)), String(localized: "Music Repository", table: "Audio-DBView"))
    }
}

private struct AudioDBPluginRootView<Content>: View where Content: View {
    @EnvironmentObject private var app: AppProvider
    @Environment(\.demoMode) private var isDemoMode

    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        AudioDBRootView(isDemoMode: isDemoMode) {
            content
        }
        .environment(\.audioDBDependencies, dependencies)
    }

    private var dependencies: AudioDBDependencies {
        AudioDBDependencies(
            audioRepo: { AudioPlugin.getAudioRepo() },
            audioDisk: { AudioPlugin.getAudioDisk() },
            supportedExtensions: AudioPlugin.supportedExtensions,
            isDesktop: Config.isDesktop,
            isNotDesktop: Config.isNotDesktop,
            showDBView: { app.showDBView() },
            isImporting: $app.isImporting
        )
    }
}

private struct AudioDBPluginTabView: View {
    @EnvironmentObject private var app: AppProvider
    let demoMode: Bool

    var body: some View {
        AudioDBView(isDemoMode: demoMode)
            .environment(\.audioDBDependencies, dependencies)
    }

    private var dependencies: AudioDBDependencies {
        AudioDBDependencies(
            audioRepo: { AudioPlugin.getAudioRepo() },
            audioDisk: { AudioPlugin.getAudioDisk() },
            supportedExtensions: AudioPlugin.supportedExtensions,
            isDesktop: Config.isDesktop,
            isNotDesktop: Config.isNotDesktop,
            showDBView: { app.showDBView() },
            isImporting: $app.isImporting
        )
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}

#Preview("App - Demo") {
    ContentView()
        .inRootView()
        .inDemoMode()
        .withDebugBar()
}
