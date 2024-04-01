import SwiftUI
import OSLog

struct BtnNext: View {
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var appManager: AppManager

    var body: some View {
        ControlButton(title: "下一曲",size: 28, systemImage: "forward.fill", onTap: {
            do {
                try audioManager.next(manual: true)
            } catch let e {
                appManager.setFlashMessage(e.localizedDescription)
            }
        })
    }
}

#Preview {
    RootView(content: {
        ContentView()
    })
}

#Preview {
    RootView(content: {
        Centered {
            BtnNext()
        }
    })
}
