import CisumUI
import MagicPlayMan
import SwiftUI

/// 上一曲按钮
struct PreviousButton: View {
    @EnvironmentObject var man: PlayMan
    @Environment(\.demoMode) var isDemoMode
    @LumiTheme private var appTheme

    private let size: CGFloat = 32

    var body: some View {
        Image.cisumBackward
            .font(.system(size: self.size * 0.6))
            .foregroundStyle(appTheme.textSecondary)
            .frame(width: size, height: size)
            .cisumCard(.ultraThinMaterial)
            .cisumRoundedFull()
            .cisumHoverScale(105)
            .cisumButton {
                man.previous()
            }
            .shadow(color: appTheme.background.opacity(0.10), radius: 4, y: 1)
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
