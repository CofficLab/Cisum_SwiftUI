import CisumUI
import MagicPlayMan
import SwiftUI

struct BtnMore: View {
    @EnvironmentObject var app: AppProvider
    @Environment(\.demoMode) var isDemoMode
    @Environment(\.localization) private var loc
    @LumiTheme private var appTheme

    private let size: CGFloat = 32

    var body: some View {
        Label(accessibilityLabel, systemImage: .cisumIconMore)
            .labelStyle(.iconOnly)
            .font(.system(size: self.size * 0.6))
            .frame(width: size, height: size)
            .foregroundStyle(appTheme.textSecondary)
            .cisumCard(.ultraThinMaterial)
            .cisumRoundedFull()
            .cisumPlaybackControl(accessibilityLabel: accessibilityLabel) {
                app.toggleDBView()
            }
            .shadow(color: appTheme.background.opacity(0.10), radius: 4, y: 1)
    }

    private var accessibilityLabel: String {
        app.showDB ? loc.closeMediaLibrary : loc.openMediaLibrary
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
