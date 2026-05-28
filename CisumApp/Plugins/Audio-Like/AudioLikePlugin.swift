import Foundation
import MagicKit
import OSLog
import SwiftData
import SwiftUI

actor AudioLikePlugin: SuperPlugin, SuperLog {
    static let shared = AudioLikePlugin()
    static let emoji = "❤️"
    static let verbose = false
    static var shouldRegister: Bool { true }
    static var order: Int { 3 }

    nonisolated var title: String { String(localized: "Audio Like", table: "Audio-Like") }
    nonisolated var description: String { String(localized: "Manage and store audio like status", table: "Audio-Like") }
    let iconName = "heart"

    /// 提供喜欢管理功能的根视图包装器
    @MainActor func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(AudioLikeRootView { content() })
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
