import SwiftUI

struct BtnMode: View {
    @EnvironmentObject var app: AppManager
    @EnvironmentObject var playMan: PlayMan

    var autoResize = false

    var body: some View {
        ControlButton(
            title: "模式",
            image: getImageName(),
            dynamicSize: autoResize,
            onTap: {
                playMan.switchMode()
                app.setFlashMessage("\(playMan.mode.description)")
            })
    }

    private func getImageName() -> String {
        switch playMan.mode {
        case .Order:
            return "repeat"
        case .Loop:
            return "repeat.1"
        case .Random:
            return "shuffle"
        }
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}

#Preview {
    BootView {
        Centered {
            BtnMode()
        }
    }
}
