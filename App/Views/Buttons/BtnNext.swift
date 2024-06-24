import OSLog
import SwiftUI

struct BtnNext: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var diskManager: DataManager
    @EnvironmentObject var playMan: PlayMan

    var autoResize = false

    var body: some View {
        ControlButton(title: "下一曲", image: "forward.fill", dynamicSize: autoResize, onTap: {
            playMan.onNext()
        })
    }
}

#Preview {
    LayoutView()
}
