import MagicKit
import OSLog
import SwiftUI

actor LikeButtonPlugin: SuperPlugin, PluginRegistrant, SuperLog {
    let description: String = "喜欢/取消喜欢 按钮"
    let iconName: String = .iconHeart
    private static var enabled: Bool { false }
    private static var verbose: Bool { false }
    nonisolated static let emoji = "🦁"

    @MainActor
    func addToolBarButtons() -> [(id: String, view: AnyView)] {
        return [(id: "like-toggle", view: AnyView(LikeToggleButtonView()))]
    }
}

private struct LikeToggleButtonView: View, SuperLog {
    nonisolated static let emoji = "🦁"
    static let verbose = false
    
    @EnvironmentObject var man: PlayMan

    var body: some View {
        if Self.verbose {
            os_log("\(self.t)开始渲染")
        }

        return Group {
            if man.asset == nil {
                EmptyView()
            } else {
                man.makeLikeButtonView(size: .mini, shape: .circle, shapeVisibility: .onHover)
            }
        }
    }
}

// MARK: - PluginRegistrant

extension LikeButtonPlugin {
    @objc static func register() {
        guard Self.enabled else {
            return
        }

        Task {
            if Self.verbose {
                os_log("\(self.t)🚀🚀🚀 Register")
            }

            await PluginRegistry.shared.register(id: "LikeButton", order: 21) {
                LikeButtonPlugin()
            }
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
            .frame(width: 500, height: 800)
    }
#endif

#if os(iOS)
    #Preview("iPhone") {
        ContentView()
    .inRootView()
    }
#endif
