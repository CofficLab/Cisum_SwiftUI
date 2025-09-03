import MagicCore
import OSLog
import SwiftUI

actor LikeButtonPlugin: SuperPlugin {
    let label = "LikeButton"
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

private struct LikeToggleButtonView: View {
    @EnvironmentObject var man: PlayMan

    var body: some View {
        os_log("LikeToggleButtonView 开始渲染")
        
        return Group {
            if man.asset == nil {
                EmptyView()
            } else {
                man.makeLikeButtonView(size: .mini, shape: .circle, shapeVisibility: .onHover)
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


