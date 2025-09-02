import MagicCore
import SwiftUI

struct BtnToggleDB: View {
    @EnvironmentObject var app: AppProvider

    var body: some View {
        MagicButton.simple(
            icon: .iconMore,
            style: .secondary,
            action: {
                app.toggleDBView()
            })
        .magicShape(.circle)
        .magicSize(.auto)
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}


