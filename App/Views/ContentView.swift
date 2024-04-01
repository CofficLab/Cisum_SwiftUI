import SwiftUI
import OSLog

struct ContentView: View {
    var play: Bool = false

    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var audioManager: AudioManager
    
    init() {
        os_log("\(Logger.isMain)🚩 ContentView::init")
    }

    var body: some View {
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
            
            // 播放过程中出现的错误
            if let e = audioManager.playerError {
                CardView(background: BackgroundView.type4) {
                    Text(e.localizedDescription)
                        .font(.title)
                        .foregroundStyle(.white)
                }
            }

            // 底部的状态栏
            #if os(macOS)
                VStack {
                    Spacer()
                    StatusBarView()
                }
            #endif
        }
    }
}

#Preview {
    RootView {
        ContentView()
    }
}
