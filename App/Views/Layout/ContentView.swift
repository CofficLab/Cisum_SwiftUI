import OSLog
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var app: AppManager
    @EnvironmentObject var data: DataManager

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
        .alert(isPresented: $app.showAlert, content: {
            Alert(title: Text(app.alertMessage))
        })
        .onChange(of: data.appScene, {
            try? data.chageScene(data.appScene)
            app.showScenes = false
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
