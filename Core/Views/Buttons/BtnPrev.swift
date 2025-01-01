import OSLog
import MagicKit
import MagicUI
import SwiftUI
import MagicPlayMan

struct BtnPrev: View {
    @EnvironmentObject var playMan: MagicPlayMan

    var autoResize = false

    var body: some View {
        ControlButton(
            title: "上一曲",
            image: "backward.fill",
            dynamicSize: autoResize,
            onTap: {
//                playMan.prev()
            })
        .foregroundStyle(.white)
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}

#Preview {
    RootView(content: {
        MagicCentered {
            BtnPrev()
        }
    })
}
