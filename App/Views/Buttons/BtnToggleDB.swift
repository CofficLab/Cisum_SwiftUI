import SwiftUI

struct BtnToggleDB: View {
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var appManager: AppManager
    
    var autoResize = false

    var body: some View {
        ControlButton(title: "仓库", image: "list.bullet", dynamicSize: autoResize, onTap: {
            appManager.toggleDBView()
        })
    }
}

#Preview("App") {
    AppPreview()
}

#Preview("Layout") {
    LayoutView()
}
