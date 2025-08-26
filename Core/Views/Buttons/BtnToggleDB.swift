import MagicCore
import SwiftUI

struct BtnToggleDB: View {
    @EnvironmentObject var app: AppProvider

    var body: some View {
        MagicButton(
            icon: .iconMore,
            style: .secondary,
            action: { done in
                app.toggleDBView()
                done()
            })
        .magicShape(.circle)
        .magicSize(.auto)
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}


