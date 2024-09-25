import SwiftUI
import MagicKit

struct DBSyncing: View {
    var body: some View {
        Centered {
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
        .background(BackgroundView.type1)
}

#Preview {
    BootView {
        DBView()
    }.modelContainer(Config.getContainer)
}
