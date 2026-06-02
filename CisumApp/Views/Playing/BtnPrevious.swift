import CisumUI
import MagicPlayMan
import SwiftUI

/// 上一曲按钮
struct PreviousButton: View {
    @EnvironmentObject var man: PlayMan
    @Environment(\.demoMode) var isDemoMode
    @Environment(\.localization) private var loc
    @LumiTheme private var appTheme

    private let size: CGFloat = 32

    var body: some View {
        Label(loc.previousTrack, systemImage: .cisumIconBackward)
            .labelStyle(.iconOnly)
            .font(.system(size: self.size * 0.6))
            .foregroundStyle(appTheme.textSecondary)
            .frame(width: size, height: size)
            .cisumCard(.ultraThinMaterial)
            .cisumRoundedFull()
            .cisumPlaybackControl(accessibilityLabel: loc.previousTrack) {
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
