import MagicKit
import OSLog
import SwiftUI

/**
 * 音频数据库插件：提供音频仓库列表视图。
 */
actor AudioDBPlugin: SuperPlugin {
    static let shared = AudioDBPlugin()
    static var shouldRegister: Bool { true }
    static var order: Int { 1 }

    nonisolated var title: String { String(localized: "Audio Repository", table: "Audio-DBView") }
    nonisolated var description: String { String(localized: "Audio file database view", table: "Audio-DBView") }
    let iconName = "externaldrive"

    @MainActor
    func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(AudioDBRootView { content() })
    }

    @MainActor
    func addTabView(reason: String, currentSceneName: String?, demoMode: Bool = false) -> (view: AnyView, label: String)? {
        guard currentSceneName == AudioScenePlugin.sceneName else { return nil }
        guard demoMode == false else { return nil }

        return (AnyView(AudioDBView()), String(localized: "Music Repository", table: "Audio-DBView"))
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
