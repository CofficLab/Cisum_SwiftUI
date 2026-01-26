import MagicKit
import MagicPlayMan
import SwiftUI

/// 下一曲按钮
struct NextButton: View {
    @EnvironmentObject var man: PlayMan
    @Environment(\.demoMode) var isDemoMode

    var body: some View {
        if isDemoMode {
            // 演示模式
            Button(action: {}) {
                Image(systemName: "forward.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.secondary)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .shadowSm()
        } else {
            // 正常模式
            Image(systemName: "forward.fill")
                .font(.system(size: 24))
                .foregroundColor(.secondary)
                .frame(width: 44, height: 44)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                .hoverScale(110)
                .inButtonWithAction {
                    man.next()
                }
        }
    }
}

// MARK: - Preview

#Preview("NextButton") {
    NextButton()
        .inRootView()
        .frame(height: 800)
}

#Preview("NextButton - Demo") {
    NextButton()
        .inRootView()
        .inDemoMode()
        .frame(height: 800)
}

