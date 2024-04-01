import SwiftUI

struct BtnToggleDB: View {
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var appManager: AppManager

    var body: some View {
        ControlButton(title: "仓库", size: 24, systemImage: "music.note.list", onTap: {
            appManager.showDB.toggle()
        })
    }
}

#Preview {
    RootView {
        ContentView()
    }
}

#Preview {
    RootView {
        ContentView()
    }
}
