import SwiftUI

struct BtnToggleDB: View {
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var appManager: AppManager
    
    var autoResize = false

    var body: some View {
        ControlButton(title: "仓库", systemImage: "list.bullet", dynamicSize: autoResize, onTap: {
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
