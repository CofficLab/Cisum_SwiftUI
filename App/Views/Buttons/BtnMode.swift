import SwiftUI

struct BtnMode: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var audioManager: AudioManager

    @State private var hovered: Bool = false

    var autoResize = false

    var body: some View {
        ControlButton(title: "模式", image: getImageName(), dynamicSize: autoResize, onTap: {
            audioManager.switchMode { mode in
                appManager.setFlashMessage("\(mode.description)")
            }
        })
    }

    private func getImageName() -> String {
        switch audioManager.mode {
        case .Order:
            return "repeat"
        case .Loop:
            return "repeat.1"
        case .Random:
            return "shuffle"
        }
    }
}

#Preview {
    RootView {
        ContentView()
    }
}

#Preview {
    RootView {
        Centered {
            BtnMode()
        }
    }
}
