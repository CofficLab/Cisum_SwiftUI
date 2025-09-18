import MagicCore
import OSLog
import SwiftUI

actor LikeButtonPlugin: SuperPlugin, PluginRegistrant {
    let hasPoster = false
    let description: String = "喜欢/取消喜欢 按钮"
    let iconName: String = .iconHeart
    nonisolated(unsafe) var enabled = true

    @MainActor
    func addToolBarButtons() -> [(id: String, view: AnyView)] {
        guard enabled else { return [] }
        return [(id: "like-toggle", view: AnyView(LikeToggleButtonView()))]
    }
}

private struct LikeToggleButtonView: View, SuperLog {
    nonisolated static let emoji = "🦁"
    static let verbose = false
    @EnvironmentObject var man: PlayManController

    var body: some View {
        if Self.verbose {
            os_log("\(self.t)开始渲染")
        }
        
        return Group {
            if man.playMan.asset == nil {
                EmptyView()
            } else {
                man.playMan.makeLikeButtonView(size: .mini, shape: .circle, shapeVisibility: .onHover)
            }
        }
    }
}

// MARK: - PluginRegistrant
extension LikeButtonPlugin {
    @objc static func register() {
        Task {
            await PluginRegistry.shared.register(id: "LikeButton", order: 21) {
                LikeButtonPlugin()
            }
        }
    }
}

// MARK: - Preview

#if os(macOS)
#Preview("App - Large") {
    AppPreview()
        .frame(width: 600, height: 1000)
}

#Preview("App - Small") {
    AppPreview()
        .frame(width: 500, height: 800)
}
#endif

#if os(iOS)
#Preview("iPhone") {
    AppPreview()
}
#endif


