import OSLog
import SwiftUI

struct BtnPrev: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var audioManager: AudioManager

    var body: some View {
        ControlButton(title: "上一曲",size: 28, systemImage: "backward.fill", onTap: {
            do {
                let message = try audioManager.prev(manual: true)
                os_log("\(Logger.isMain)BtnPrev::\(message)")
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
            BtnPrev()
        }
    })
}
