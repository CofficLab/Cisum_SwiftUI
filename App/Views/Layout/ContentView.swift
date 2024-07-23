import OSLog
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var data: DataProvider

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                if Config.isNotDesktop {
                    TopView()
                }

                AudioAppView()
            }

            if !app.flashMessage.isEmpty {
                CardView(background: BackgroundView.type4) {
                    Text(app.flashMessage)
                        .font(.title)
                        .foregroundStyle(.white)
                }.onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
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
        .onChange(of: data.appScene, {
            try? data.chageScene(data.appScene)
        })
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}

#Preview("App") {
    LayoutView()
}
