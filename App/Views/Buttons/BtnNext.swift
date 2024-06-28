import OSLog
import SwiftUI

struct BtnNext: View {
    @EnvironmentObject var playMan: PlayMan

    var autoResize = false

    var body: some View {
        ControlButton(
            title: "下一曲", image: "forward.fill", dynamicSize: autoResize,
            onTap: {
                playMan.next()
            })
    }
}

#Preview {
    AppPreview()
        .frame(height: 800)
}
