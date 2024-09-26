import OSLog
import SwiftUI
import MagicKit

struct ContentView: View, SuperLog, SuperThread {
    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var data: DataProvider
    @EnvironmentObject var p: PluginProvider
    @EnvironmentObject var l: LayoutProvider

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                if Config.isNotDesktop {
                    TopView()
                }

                l.layout.onAppear {
                    l.current.boot()
                }
            }

            if !app.flashMessage.isEmpty {
                CardView(background: BackgroundView.type4) {
                    Text(app.flashMessage)
                        .font(.title)
                        .foregroundStyle(.white)
                }.onAppear {
                    self.main.asyncAfter(deadline: .now() + 3.0) {
                        app.flashMessage = ""
                    }
                }
            }

            if !app.fixedMessage.isEmpty {
                CardView(background: BackgroundView.type4) {
                    Text(app.fixedMessage)
                        .font(.title)
                        .foregroundStyle(.white)
                }
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
