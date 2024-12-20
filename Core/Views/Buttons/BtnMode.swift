import SwiftUI

struct BtnMode: View {
    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var playMan: PlayMan
    @EnvironmentObject var messageManager: MessageProvider

    var autoResize = false

    var body: some View {
        ControlButton(
            title: "模式",
            image: playMan.mode.getImageName(),
            dynamicSize: autoResize,
            onTap: {
                playMan.switchMode()
                messageManager.toast("\(playMan.mode.description)")
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
        Centered {
            BtnMode()
        }
    }
}
