import OSLog
import SwiftUI
import MagicKit
import MagicUI

struct ContentView: View, SuperLog, SuperThread {
    static let emoji = "🐮"
    
    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var p: PluginProvider
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                if Config.isNotDesktop {
                    TopView()
                }

                MainView()
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
