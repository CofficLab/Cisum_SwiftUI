import Foundation
import MagicKit
import OSLog
import SwiftUI

actor AudioPlayModePlugin: SuperPlugin {
    static let shared = AudioPlayModePlugin()
    static var shouldRegister: Bool { true }

    nonisolated var title: String { String(localized: "Audio Play Mode", table: "Audio-PlayMode") }
    nonisolated var description: String { String(localized: "Audio play mode management", table: "Audio-PlayMode") }
    let iconName = "repeat"

    /// 提供播放模式管理功能的根视图包装器
    @MainActor func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(AudioPlayModeRootView { content() })
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
