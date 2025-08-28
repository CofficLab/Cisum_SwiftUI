import MagicCore
import OSLog
import SwiftUI

struct WelcomeView: View, SuperSetting, SuperLog {
    nonisolated static let emoji = "🎉"

    var body: some View {
        os_log("\(self.t)开始渲染")
        return VStack {
            Text("美好即将开始").font(.title).padding()
            
            StorageView().padding()
        }
    }
}

#Preview("Welcome") {
    RootView {
        WelcomeView()
    }
    .frame(height: 800)
}

#Preview("App - Large") {
    AppPreview()
        .frame(width: 600, height: 1000)
}

#Preview("App - Small") {
    AppPreview()
        .frame(width: 500, height: 800)
}

#if os(iOS)
#Preview("iPhone") {
    AppPreview()
}
#endif
