import CisumUI
import MagicKit
import SwiftUI

struct BtnMore: View {
    @EnvironmentObject var app: AppProvider
    @Environment(\.demoMode) var isDemoMode
    @LumiTheme private var appTheme

    private let size: CGFloat = 32

    var body: some View {
        Image.more
            .font(.system(size: self.size * 0.6))
            .frame(width: size, height: size)
            .foregroundStyle(appTheme.textSecondary)
            .inCard(.ultraThinMaterial)
            .roundedFull()
            .hoverScale(105)
            .inButtonWithAction {
                app.toggleDBView()
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
