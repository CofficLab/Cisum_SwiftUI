import Foundation
import MagicKit
import OSLog
import SwiftUI

actor AudioControlPlugin: SuperPlugin, SuperLog {
    static let shared = AudioControlPlugin()
    static let emoji = "🎮"
    static let verbose = true
    static var shouldRegister: Bool { true }

    let title = "音频播放控制"
    let description = "负责音频播放控制功能，如上一首、下一首"
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
