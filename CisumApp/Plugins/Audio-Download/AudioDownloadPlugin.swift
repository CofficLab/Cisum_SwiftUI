import Foundation
import MagicKit
import OSLog
import SwiftUI

actor AudioDownloadPlugin: SuperPlugin, SuperLog {
    static let shared = AudioDownloadPlugin()
    static let emoji = "⬇️"
    static let verbose = true
    static var shouldRegister: Bool { true }

    /// 注册顺序设为 2，在 AudioPlugin (order: 1) 之后执行
    static var order: Int { 2 }

    nonisolated var title: String { String(localized: "Audio Download", table: "Audio-Download") }
    nonisolated var description: String { String(localized: "Auto download audio files", table: "Audio-Download") }
    let iconName = "icloud.and.arrow.down"

    /// 只有当当前插件是音频插件时才提供下载管理
    @MainActor func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(AudioDownloadRootView { content() })
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
