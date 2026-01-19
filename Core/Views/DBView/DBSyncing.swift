import MagicKit
import SwiftUI

struct DBSyncing: View {
    var body: some View {
        ProgressView()
            .magicCentered()
    }
}

#Preview("App") {
    ContentView()
        .inRootView()
        .frame(height: 800)
}

#Preview {
    DBSyncing()
        .frame(width: 300, height: 300)
        .background(MagicBackground.aurora)
}
