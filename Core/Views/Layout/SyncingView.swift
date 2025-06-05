import OSLog
import MagicCore

import SwiftUI

struct SyncingView: View {
    var body: some View {
        MagicCard(background: MagicBackground.aurora) {
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
