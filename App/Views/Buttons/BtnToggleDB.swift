import SwiftUI

struct BtnToggleDB: View {
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var appManager: AppManager
    
    var size: CGFloat = 24

    var body: some View {
        ControlButton(title: "仓库", size: size, systemImage: "music.note.list", onTap: {
            appManager.showDB.toggle()
        })
    }
}

#Preview("App") {
    AppPreview()
}

#Preview("Layout") {
    LayoutView()
}
