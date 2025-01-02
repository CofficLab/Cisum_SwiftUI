import MagicUI
import SwiftUI

struct BtnToggleDB: View {
    @EnvironmentObject var app: AppProvider

    var body: some View {
        MagicButton(
            icon: "ellipsis",
            style: .secondary,
            action: {
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
