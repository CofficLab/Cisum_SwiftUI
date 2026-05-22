import CisumUI
import MagicKit
import OSLog
import SwiftUI

actor LikeButtonPlugin: SuperPlugin, SuperLog {
    let description: String = "喜欢/取消喜欢 按钮"
    let iconName: String = .cisumIconHeart
    static var shouldRegister: Bool { false }
    static var verbose: Bool { false }
    nonisolated static let emoji = "🦁"

    @MainActor
    func addToolBarButtons() -> [(id: String, view: AnyView)] {
        return [(id: "like-toggle", view: AnyView(LikeToggleButtonView()))]
    }
}

private struct LikeToggleButtonView: View, SuperLog {
    nonisolated static let emoji = "🦁"
    static let verbose = false
    /// 注册顺序设为 21，在其他插件之后执行
    static var order: Int { 21 }
    @EnvironmentObject var man: PlayMan

    var body: some View {
        if Self.verbose {
            os_log("\(self.t)开始渲染")
        }

        return Group {
            if man.asset == nil {
                EmptyView()
            } else {
                man.makeLikeButtonView(size: 24)
            }
        }
    }
}

// MARK: - Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
