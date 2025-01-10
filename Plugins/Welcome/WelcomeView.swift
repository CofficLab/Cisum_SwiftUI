import MagicKit

import OSLog
import SwiftUI

struct WelcomeView: View, SuperSetting, SuperLog {
    nonisolated static let emoji = "🎉"

    var body: some View {
        VStack {
            Text("美好即将开始").font(.title).padding()
            
            StorageView().padding()
        }
    }
}
