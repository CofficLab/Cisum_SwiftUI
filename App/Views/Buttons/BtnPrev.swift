import OSLog
import SwiftUI

struct BtnPrev: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var audioManager: PlayManager

    var autoResize = false

    var body: some View {
        ControlButton(title: "上一曲", image: "backward.fill", dynamicSize: autoResize, onTap: {
            audioManager.prev(manual: true)
        })
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}

#Preview {
    RootView(content: {
        Centered {
            BtnPrev()
        }
    })
}
