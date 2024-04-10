import SwiftUI

struct BtnAdd: View {
    @EnvironmentObject var appManager: AppManager

    var body: some View {
        Button("添加", systemImage: "plus.circle") {
            appManager.showDB = true
            appManager.isImporting = true
        }
    }
}

#Preview {
    RootView {
        VStack {
            BtnAdd()
            BtnAdd().buttonStyle(.borderedProminent)
            BtnAdd().labelStyle(.iconOnly)
            
            DBView()
        }
    }.modelContainer(AppConfig.getContainer())
}
