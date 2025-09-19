import MagicCore
import MagicUI
import SwiftUI

struct BtnAdd: View {
    @EnvironmentObject var appManager: AppProvider

    var body: some View {
        MagicButton(
            icon: .iconAdd,
            title: "添加",
            action: { done in
                withAnimation {
                    if appManager.showDB {
                        appManager.isImporting = true
                    } else {
                        appManager.showDBView()
                    }
                    
                    done()
                }
            }
        )
    }
}

#Preview("App - Large") {
    AppPreview()
        .frame(width: 600, height: 1000)
}

#Preview("App - Small") {
    AppPreview()
        .frame(width: 600, height: 600)
}

#if os(iOS)
#Preview("iPhone") {
    AppPreview()
}
#endif
