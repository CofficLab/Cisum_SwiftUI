import SwiftUI

struct BtnToggleDB: View {
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
        .frame(height: 800)
}

#Preview("Layout") {
    LayoutView()
}
