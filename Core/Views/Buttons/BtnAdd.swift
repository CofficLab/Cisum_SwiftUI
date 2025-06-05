import MagicCore
import SwiftUI

struct BtnAdd: View {
    @EnvironmentObject var appManager: AppProvider

    var body: some View {
        MagicButton(
            icon: .iconAdd,
            title: "添加",
            action: {
                withAnimation {
                    if appManager.showDB {
                        appManager.isImporting = true
                    } else {
                        appManager.showDBView()
                    }
                }
            }
        )
    }
}
