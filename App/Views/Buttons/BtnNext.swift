import OSLog
import SwiftUI

struct BtnNext: View {
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var appManager: AppManager

    var body: some View {
        ControlButton(title: "下一曲", size: 28, systemImage: "forward.fill", onTap: {
            audioManager.next(manual: true)
        })
    }
}

#Preview {
    LayoutView()
}
