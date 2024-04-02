import SwiftUI

struct BtnMode: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var audioManager: AudioManager

    @State private var hovered: Bool = false

    var body: some View {
        ControlButton(title:"模式",size:24,systemImage: getImageName(), onTap: {
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
