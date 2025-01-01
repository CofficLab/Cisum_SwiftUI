import OSLog
import SwiftUI
import MagicKit
import MagicUI
import MagicPlayMan

struct BtnNext: View, SuperEvent {
    @EnvironmentObject var playMan: MagicPlayMan

    var autoResize = false

    var body: some View {
        ControlButton(
            title: "下一曲", image: "forward.fill",
            dynamicSize: autoResize,
            onTap: {
                Task {
                    await self.playMan.next()
                }
            })
            .foregroundStyle(.white)
    }
}

#Preview {
    AppPreview()
        .frame(height: 800)
}
