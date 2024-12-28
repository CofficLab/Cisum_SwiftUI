import MagicKit
import MagicUI
import OSLog
import SwiftUI

struct WelcomeView: View, SuperSetting, SuperLog {
    static var emoji: String = "🎉"

    var body: some View {
        VStack {
            Text("美好即将开始").font(.title).padding()
            
            StorageView().padding()
        }
    }
}
