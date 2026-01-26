import MagicKit
import SwiftUI

struct BtnMore: View {
    @EnvironmentObject var app: AppProvider
    @Environment(\.demoMode) var isDemoMode

    var body: some View {
        if isDemoMode {
            // 演示模式
            Image.more
                .font(.system(size: 24))
                .foregroundColor(.secondary)
                .frame(width: 44, height: 44)
        } else {
            // 正常模式
            Image.more
                .frame(width: 32, height: 32)
                .background(.ultraThinMaterial, in: Circle())
                .hoverScale(110)
                .inButtonWithAction {
                    app.toggleDBView()
                }
        }
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
