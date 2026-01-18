import Foundation
import MagicKit
import OSLog
import SwiftUI

actor AudioControlPlugin: SuperPlugin, SuperLog, PluginRegistrant {
    static let emoji = "🎮"
    static let verbose = true
    private static var enabled: Bool { true }

    let title = "音频播放控制"
    let description = "负责音频播放控制功能，如上一首、下一首"
    let iconName = "playpause"
    let isGroup = false

    /// 提供播放控制功能的根视图包装器
    @MainActor func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(AudioControlRootView { content() })
    }
}

// MARK: - PluginRegistrant

extension AudioControlPlugin {
    @objc static func register() {
        guard Self.enabled else {
            return
        }

        Task {
            if Self.verbose {
                os_log("\(self.t)🚀 Register")
            }
            // 注册顺序设为 4，确保在其他音频相关插件之后
            await PluginRegistry.shared.register(order: 4) { Self() }
        }
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
