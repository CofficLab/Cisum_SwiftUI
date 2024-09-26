import SwiftUI

struct BtnToggleDB: View {
    @EnvironmentObject var app: AppProvider

    var autoResize = false

    var body: some View {
        ControlButton(
            title: "仓库",
            image: "list.bullet",
            dynamicSize: autoResize,
            onTap: {
                app.toggleDBView()
            })
        .foregroundStyle(.white)
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}

#Preview("Layout") {
    LayoutView()
}
