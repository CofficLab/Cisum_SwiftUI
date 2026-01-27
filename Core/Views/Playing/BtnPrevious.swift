import MagicKit
import MagicPlayMan
import SwiftUI

/// 上一曲按钮
struct PreviousButton: View {
    @EnvironmentObject var man: PlayMan
    @Environment(\.demoMode) var isDemoMode

    var body: some View {
        Image.backward
            .foregroundColor(.secondary)
            .frame(width: 32, height: 32)
            .inCard(.ultraThinMaterial)
            .roundedFull()
            .hoverScale(105)
            .inButtonWithAction {
                man.previous()
            }
            .shadowSm()
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .inPreviewMode()
}
