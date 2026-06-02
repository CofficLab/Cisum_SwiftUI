import CisumUI
import MagicKit
import SwiftUI

struct DBSyncing: View {
    var body: some View {
        ProgressView()
            .cisumCentered()
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}

#Preview {
    DBSyncing()
        .frame(width: 300, height: 300)
        .background(CisumMagicBackground.aurora)
}
