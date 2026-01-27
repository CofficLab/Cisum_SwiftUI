import MagicKit
import SwiftUI

struct BtnMore: View {
    @EnvironmentObject var app: AppProvider
    @Environment(\.demoMode) var isDemoMode

    var body: some View {
        Image.more
            .frame(width: 32, height: 32)
            .inCard(.ultraThinMaterial)
            .roundedFull()
            .hoverScale(105)
            .inButtonWithAction {
                app.toggleDBView()
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
