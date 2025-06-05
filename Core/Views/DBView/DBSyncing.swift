import SwiftUI
import MagicCore


struct DBSyncing: View {
    var body: some View {
        MagicCentered {
            ProgressView()
        }
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}

#Preview {
    DBSyncing()
        .frame(width: 300, height: 300)
        .background(MagicBackground.aurora)
}
