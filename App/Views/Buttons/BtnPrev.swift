import OSLog
import SwiftUI

struct BtnPrev: View {
    @EnvironmentObject var playMan: PlayMan

    var autoResize = false

    var body: some View {
        ControlButton(
            title: "上一曲",
            image: "backward.fill",
            dynamicSize: autoResize,
            onTap: {
                playMan.prev()
            })
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}

#Preview {
    BootView(content: {
        Centered {
            BtnPrev()
        }
    })
}
