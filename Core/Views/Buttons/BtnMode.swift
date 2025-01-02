import SwiftUI
import MagicKit
import MagicUI
import MagicPlayMan

struct BtnMode: View {
    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var playMan: MagicPlayMan
    @EnvironmentObject var messageManager: MessageProvider

    var autoResize = false

    var body: some View {
        ControlButton(
            title: "模式",
            image: playMan.playMode.iconName,
            dynamicSize: autoResize,
            onTap: {
                playMan.togglePlayMode()
                messageManager.hub("\(playMan.playMode.displayName)")
            })
        .foregroundStyle(.white)
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}

#Preview {
    RootView {
        MagicCentered {
            BtnMode()
        }
    }
}
