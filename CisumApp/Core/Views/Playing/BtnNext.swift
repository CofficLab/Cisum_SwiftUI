import CisumUI
import MagicPlayMan
import SwiftUI

/// 下一曲按钮
struct NextButton: View {
    @EnvironmentObject var man: PlayMan
    @Environment(\.demoMode) var isDemoMode
    @LumiTheme private var appTheme

    private let size: CGFloat = 32

    var body: some View {
        Image.cisumForward
            .font(.system(size: self.size * 0.6))
            .foregroundStyle(appTheme.textSecondary)
            .frame(width: size, height: size)
            .cisumCard(.ultraThinMaterial)
            .cisumRoundedFull()
            .cisumPlaybackControl {
                man.next()
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
