import MagicKit
import MagicPlayMan
import SwiftUI

/// 上一曲按钮
struct PreviousButton: View {
    @EnvironmentObject var man: PlayMan
    @Environment(\.demoMode) var isDemoMode

    var body: some View {
        if isDemoMode {
            // 演示模式
            Button(action: {}) {
                Image(systemName: "backward.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.secondary)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .shadowSm()
        } else {
            // 正常模式
            Image(systemName: "backward.fill")
                .font(.system(size: 24))
                .foregroundColor(.secondary)
                .frame(width: 44, height: 44)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                .hoverScale(110)
                .inButtonWithAction {
                    man.previous()
                }
        }
    }
}


// MARK: - Preview

#Preview("PreviousButton") {
    PreviousButton()
        .inRootView()
        .frame(height: 800)
}

#Preview("PreviousButton - Demo") {
    PreviousButton()
        .inRootView()
        .inDemoMode()
        .frame(height: 800)
}
