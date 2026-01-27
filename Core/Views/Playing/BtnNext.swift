import MagicKit
import MagicPlayMan
import SwiftUI

/// 下一曲按钮
struct NextButton: View {
    @EnvironmentObject var man: PlayMan
    @Environment(\.demoMode) var isDemoMode

    var body: some View {
        Image.forward
            .frame(width: 32, height: 32)
            .inCard()
            .roundedFull()
            .hoverScale(105)
            .inButtonWithAction {
                man.next()
            }
            .shadowSm()
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .inRootView()
        .inPreviewMode()
}
