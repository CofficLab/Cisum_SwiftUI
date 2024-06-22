import SwiftUI

struct BtnMode: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var playMan: PlayMan

    @State private var hovered: Bool = false

    var autoResize = false

    var body: some View {
        ControlButton(title: "模式", image: getImageName(), dynamicSize: autoResize, onTap: {
            playMan.switchMode { mode in
                appManager.setFlashMessage("\(mode.description)")
            }
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
    RootView {
        Centered {
            BtnMode()
        }
    }
}
