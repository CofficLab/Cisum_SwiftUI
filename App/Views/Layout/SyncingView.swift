import OSLog
import SwiftUI

struct SyncingView: View {
    var body: some View {
        CardView(background: BackgroundView.type4) {
            Text("正在读取仓库")
                .font(.title)
                .foregroundStyle(.white)
        }
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}

#Preview("App") {
    LayoutView()
}
