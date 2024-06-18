import OSLog
import SwiftUI

struct BtnPrev: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var audioManager: PlayManager

    var autoResize = false

    var body: some View {
        ControlButton(title: "上一曲", image: "backward.fill", dynamicSize: autoResize, onTap: {
            do {
                try audioManager.prev(manual: true)
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
