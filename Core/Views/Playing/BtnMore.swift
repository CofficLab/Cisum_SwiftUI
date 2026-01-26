import MagicKit
import SwiftUI

struct BtnMore: View {
    @EnvironmentObject var app: AppProvider
    @Environment(\.demoMode) var isDemoMode

    var body: some View {
        Image.more
            .frame(width: 32, height: 32)
            .inCard()
            .roundedFull()
            .hoverScale(110)
            .inButtonWithAction {
                app.toggleDBView()
            }
            .shadowSm()
    }
}

#Preview("App") {
    ContentView()
        .inRootView()
        .frame(height: 800)
}

#Preview("App - Demo") {
    ContentView()
        .inRootView()
        .inDemoMode()
        .frame(height: 800)
}
