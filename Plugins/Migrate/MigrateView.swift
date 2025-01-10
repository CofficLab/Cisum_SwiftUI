import MagicKit

import OSLog
import SwiftUI

struct MigrateView: View, SuperThread {
    @EnvironmentObject var appManager: AppProvider
    @EnvironmentObject var m: MessageProvider

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Text("Migrate")
            }
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
