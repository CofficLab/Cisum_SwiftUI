import OSLog
import SwiftUI

struct BtnNext: View {
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var appManager: AppManager

    var autoResize = false

    var body: some View {
        ControlButton(title: "下一曲", image: "forward.fill", dynamicSize: autoResize, onTap: {
            audioManager.next(manual: true)
        })
    }
}

#Preview {
    LayoutView()
}
