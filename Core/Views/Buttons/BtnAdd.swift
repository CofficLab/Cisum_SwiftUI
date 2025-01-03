import SwiftUI

struct BtnAdd: View {
    @EnvironmentObject var appManager: AppProvider

    var body: some View {
        Button("添加", systemImage: "plus.circle") {
            withAnimation {
                if appManager.showDB {
                    appManager.isImporting = true
                } else {
                    appManager.showDBView()
                }
            }
        }
    }
}
