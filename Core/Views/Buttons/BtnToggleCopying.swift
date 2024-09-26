import SwiftUI

struct BtnToggleCopying: View {
    @EnvironmentObject var app: AppProvider
    
    var autoResize = false

    var body: some View {
        ControlButton(
            title: "仓库",
            image: "list.bullet",
            dynamicSize: autoResize,
            onTap: {
                app.showDB = true
                app.showCopying.toggle()
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
