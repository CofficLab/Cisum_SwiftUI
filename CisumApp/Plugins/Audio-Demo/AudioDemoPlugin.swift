import CisumUI
import MagicKit
import OSLog
import SwiftUI

/**
 * 演示模式插件
 */
actor AudioDemoPlugin: SuperPlugin {
    static let shared = AudioDemoPlugin()
    
    static var shouldRegister: Bool { true }
    static var order: Int { 1 }

    nonisolated var title: String { String(localized: "Audio Repository", table: "Audio-Demo") }
    nonisolated var description: String { String(localized: "Audio file database view", table: "Audio-Demo") }
    let iconName = "externaldrive"

    @MainActor
    func addTabView(reason: String, currentSceneName: String?, demoMode: Bool = false) -> (view: AnyView, label: String)? {
        guard currentSceneName == AudioScenePlugin.sceneName else { return nil }
        guard demoMode else { return nil }

        return (AnyView(AudioListDemo()), String(localized: "Music Repository", table: "Audio-Demo"))
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

#Preview("App Store Album Art") {
    AppStoreAlbumArt()
        .cisumPreviewContainer(.cisumMacBook13, scale: 1)
}
