import Foundation
import MagicKit
import OSLog
import SwiftUI

actor AudioControlPlugin: SuperPlugin, SuperLog {
    static let shared = AudioControlPlugin()
    static let emoji = "🎮"
    static let verbose = true
    static var shouldRegister: Bool { true }

    nonisolated var title: String { String(localized: "Audio Playback Control", table: "Audio-Control") }
    nonisolated var description: String { String(localized: "Audio playback control, such as previous and next", table: "Audio-Control") }
    let iconName = "playpause"

    /// 提供播放控制功能的根视图包装器
    @MainActor func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(AudioControlRootView { content() })
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
