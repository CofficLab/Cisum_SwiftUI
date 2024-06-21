import OSLog
import SwiftUI

struct BtnNext: View {
    @EnvironmentObject var audioManager: PlayManager
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var diskManager: DiskManager

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
