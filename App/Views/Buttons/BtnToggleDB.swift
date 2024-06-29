import SwiftUI

struct BtnToggleDB: View {
    @EnvironmentObject var app: AppManager

    var autoResize = false

    var body: some View {
        ControlButton(
            title: "仓库",
            image: "list.bullet",
            dynamicSize: autoResize,
            onTap: {
                app.toggleDBView()
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
