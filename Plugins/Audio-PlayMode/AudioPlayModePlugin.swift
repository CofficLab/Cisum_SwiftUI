import Foundation
import MagicKit
import OSLog
import SwiftUI

actor AudioPlayModePlugin: SuperPlugin {
    static var shouldRegister: Bool { true }

    let title = "音频播放模式管理"
    let description = "负责音频播放模式的设置和管理"
    let iconName = "repeat"

    /// 提供播放模式管理功能的根视图包装器
    @MainActor func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(AudioPlayModeRootView { content() })
    }
}

// MARK: - Preview

#if os(macOS)
    #Preview("App - Large") {
        ContentView()
            .inRootView()
            .frame(width: 600, height: 1000)
    }

    #Preview("App - Small") {
        ContentView()
            .inRootView()
            .frame(width: 600, height: 600)
    }
#endif

#if os(iOS)
    #Preview("iPhone") {
        ContentView()
            .inRootView()
    }
#endif
