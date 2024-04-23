import SwiftUI
import OSLog

struct ContentView: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var audioManager: AudioManager

    var body: some View {
        GeometryReader { geo in
            ZStack {
                HomeView()
                    .alert(isPresented: $appManager.showAlert, content: {
                        Alert(title: Text(appManager.alertMessage))
                    })

                if !appManager.flashMessage.isEmpty {
                    CardView(background: BackgroundView.type4) {
                        Text(appManager.flashMessage)
                            .font(.title)
                            .foregroundStyle(.white)
                    }.onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            appManager.flashMessage = ""
                        }
                    }
                }

                if !appManager.fixedMessage.isEmpty {
                    CardView(background: BackgroundView.type4) {
                        Text(appManager.fixedMessage)
                            .font(.title)
                            .foregroundStyle(.white)
                    }
                }
                
//                if AppConfig.debug {
//                    Text("\(Int(geo.size.width)) x \(Int(geo.size.height))")
//                        .foregroundStyle(.red)
//                        .font(.system(size: geo.size.height / 10))
//                }
            }
        }
    }
}

#Preview("App") {
    LayoutView()
}
